local k = import 'kubernetes.libsonnet';

local name = 'mosquitto';

local configName = 'mosquitto-conf';
local fileName = 'mosquitto.conf';

local ports = [{
  port: 1883,
  name: 'mqtt',
  protocol: 'TCP',
}];

k.namespace.scope('mqtt', [
  k.configMap(configName, {
    [fileName]: importstr 'mosquitto.conf',
  }),

  k.deployment.create(name, [
    {
      image: 'eclipse-mosquitto:latest',
    }
    + k.container.ports(ports)
    + k.container.mount.configMap(
      configName,
      fileName,
      '/mosquitto/config/%s' % fileName
    ),
  ])
  + k.deployment.volume.configMap(configName, [fileName]),

  k.service.create(name, type='LoadBalancer') 
  + k.service.ports(ports) 
  + k.service.staticIP('10.50.1.25'),
], create=true)
