local k = import 'kubernetes.libsonnet';

local ports = [{
  port: 80,
  protocol: 'TCP',
  name: 'http',
}];

local configName = 'zigbee2mqtt-config';
local configFile = 'configuration.yaml';

k.namespace.scope('mqtt', [
  k.configMap(configName, {
    [configFile]: std.manifestYamlDoc({
      mqtt: {
        base_topic: 'zigbee2mqtt',
        server: 'mqtt://mqtt.mqtt.svc.cluster.local',
      },
      serial: {
        port: 'tcp://192.168.2.154:6638',
      },
      frontend: {
        port: 80,
      },
      advanced: {
        network_key: 'GENERATE',
      },
    }),
  }),
  {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'zigbee2mqtt-data',
    },
    spec: {
      storageClassName: 'local-path',
      accessModes: ['ReadWriteOnce'],
      resources: {
        requests: {
          storage: '3Gi',
        },
      },
    },
  },
  k.deployment.create('zigbee2mqtt', [
    { image: 'koenkk/zigbee2mqtt' }
    + k.container.ports(ports)
    + k.container.mount('zigbee2mqtt-data', '/app/data/'),
  ])
  + k.deployment.initContainers([
    k.busyBox('cp /tmp/%s /app/data/' % configFile)
    + k.container.mount('zigbee2mqtt-data', '/app/data/')
    + k.container.mount(configName, '/tmp/%s' % configFile, subPath=configFile),
  ])
  + k.deployment.volume.configMap(configName, [configFile])
  + k.deployment.volume.pvc('zigbee2mqtt-data'),

  k.service.create('zigbee2mqtt', ports),

  {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      annotations: {
        'cert-manager.io/cluster-issuer': 'letsencrypt-issuer',
      },
      name: 'zigbee2mqtt',
    },
    spec: {
      ingressClassName: 'cilium',
      rules: [{
        host: 'z2mqtt.kotee.co',
        http: {
          paths: [{
            path: '/',
            pathType: 'Prefix',
            backend: {
              service: {
                name: 'zigbee2mqtt',
                port: {
                  name: 'http',
                },
              },
            },
          }],
        },
      }],
      tls: [{
        hosts: ['pihole.kotee.co'],
        secretName: 'zigbee2mqtt-tls',
      }],
    },
  },
])
