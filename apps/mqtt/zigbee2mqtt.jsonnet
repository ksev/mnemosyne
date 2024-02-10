local k = import 'kubernetes.libsonnet';

local ports = [{
  port: 80,
  protocol: 'TCP',
  name: 'http'
}];

local configName = 'zigbee2mqtt-config';
local configFile = 'configuration.yaml';

k.namespace.scope('mqtt', [
  k.configMap(configName, {
    [configFile]: std.manifestYamlDoc({
      mqtt: {
        base_topic: 'zigbee2mqtt',
        server: 'mqtt://mqtt.mqtt.svc.cluster.local'
      },
      serial: {
        port: 'tcp://192.168.2.154:6638'
      },
      frontend: {
        port: 80
      },
      advanced: {
        network_key: 'GENERATE'
      }
    }),
  }),
  k.deployment.create('zigbee2mqtt', [
    { image: 'koenkk/zigbee2mqtt' }
    + k.container.ports(ports) 
    + k.container.mount.configMap(
      configName,
      configFile,
      '/app/data/%s' % configFile
    ),
  ])
  + k.deployment.volume.configMap(configName, [configFile]),

  k.service.create('zigbee2mqtt', ports) 
])

