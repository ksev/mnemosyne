local k = import 'kubernetes.libsonnet';

local name = 'mosquitto';

local configName = 'mosquitto-conf';
local fileName = 'mosquitto.conf';

local ports = [{ 
  port: 1883, 
  name: 'mqtt', 
  protocol: 'TCP' 
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

  k.service.create(name) + k.service.ports(ports),

  {
    apiVersion: 'gateway.networking.k8s.io/v1',
    kind: 'Gateway',
    metadata: {
      name: '%s-gateway' % name,
    },
    spec: {
      gatewayClassName: 'cilium',
      listeners: [{
        name: 'mqtt',
        protocol: 'TCP',
        port: 1883,
        allowedRoutes: {
          kinds: [{
            kind: 'TCPRoute'
          }]
        }
      }]
    }
  },

  {
    apiVersion: 'gateway.networking.k8s.io/v1alpha2',
    kind: 'TCPRoute',
    metadata: {
      name: 'mqtt-tcp-route',      
    },
    spec: {
      parentRefs: [{
         name: '%s-gateway' % name,
          sectionName: 'mqtt' 
      }],
      hostnames: ['mqtt.kotee.co'],
      rules: [{
        backendRefs: [{
          name: name,
          port: 'mqtt'
        }]
      }]
    }
  }
], create=true)
