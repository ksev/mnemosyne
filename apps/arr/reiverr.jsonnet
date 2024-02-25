
local k = import 'kubernetes.libsonnet';

local name = 'reiverr';
local storageName = '%s-storage' % name;

local ports = [
  k.ports.http {
    port: 9494
  }
];

k.namespace.scope('arr', [
  k.pvc(storageName, '150Mi'),

  k.deployment.create(name, [
    { 
      image: 'ghcr.io/aleksilassila/reiverr:latest',
    }
    + k.container.ports(ports)
    + k.container.mount(storageName, '/config')
  ])
  + k.deployment.volume.pvc(storageName),

  k.service.create(name, ports),

  k.ingress.enableTLS(
    k.ingress.create(name, [
      k.ingress.rule(
        '%s.kotee.co' % name,
        [{
          path: '/',
          pathType: 'Prefix',
          backend: k.ingress.service(name, 'http'),
        }]
      ),
    ])
  ),
])
