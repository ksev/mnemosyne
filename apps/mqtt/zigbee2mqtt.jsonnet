local k = import 'kubernetes.libsonnet';

local ports = [k.ports.http];

local configName = 'zigbee2mqtt-config';
local configFile = 'configuration.yaml';

k.namespace.scope('mqtt', [
  k.configMap(configName, {
    [configFile]: std.manifestYamlDoc({
      mqtt: {
        base_topic: 'zigbee2mqtt',
        server: 'mqtt://mosquitto',
      },
      serial: {
        port: 'tcp://192.168.2.154:6638',
        adapter: 'zstack'
      },
      frontend: {
        port: 80,
      },
      advanced: {
        network_key: 'GENERATE',
        pan_id: 'GENERATE',
      },
    }),
  }),

  k.pvc('zigbee2mqtt-data', '3Gi'),

  k.deployment.create('zigbee2mqtt', [
    { image: 'koenkk/zigbee2mqtt' }
    + k.container.ports(ports)
    + k.container.mount('zigbee2mqtt-data', '/app/data/'),
  ])
  + k.deployment.initContainers([
    k.busyBox('cp -n /tmp/%s /app/data/' % configFile)
    + k.container.mount('zigbee2mqtt-data', '/app/data/')
    + k.container.mount(configName, '/tmp/%s' % configFile, subPath=configFile),
  ])
  + k.deployment.volume.configMap(configName, [configFile])
  + k.deployment.volume.pvc('zigbee2mqtt-data'),

  k.service.create('zigbee2mqtt', ports),

  k.ingress.enableTLS(
    k.ingress.create('zigbee2mqtt', [
      k.ingress.rule(
        'z2mqtt.kotee.co',
        [{
          path: '/',
          pathType: 'Prefix',
          backend: k.ingress.service('zigbee2mqtt', 'http'),
        }]
      ),
    ])
  ),
])
