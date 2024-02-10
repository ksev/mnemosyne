local k = import 'kubernetes.libsonnet';

// mosquitto.conf:/mosquitto/config/mosquitto.conf

local configName = 'mosquitto-conf';
local fileName = 'mosquitto.conf';

k.scoped('mqtt', [
  k.configMap(configName, {
    [fileName]: importstr 'mosquitto.conf',
  }),
  k.deployment('mosquitto', [
    {
      image: 'eclipse-mosquitto:latest',
    }
    + k.container.ports([1883, 9001])
    + k.container.mount.configMap(
      configName,
      fileName,
      '/mosquitto/config/%s' % fileName
    ),
  ])
  + k.volume.configMap(configName, [fileName]),
], create=true)
