local k = import 'kubernetes.libsonnet';

local storageName = 'prowlarr-storage';
local ports = [
  k.ports.http {
    port: 9696,
  },
];

k.namespace.scope('arr', [
  k.pvc(storageName, '5Gi'),

  k.deployment.create('prowlarr', [
    { image: 'lscr.io/linuxserver/prowlarr:latest' }
    + k.container.ports(ports)
    + k.container.mount(storageName, '/config')
    + k.container.liveHttp({
      path: '/login',
      port: 9696,
    }),
  ])
  + k.deployment.volume.pvc(storageName),

  k.service.create('prowlarr', ports),

  k.ingress.enableTLS(
    k.ingress.create('prowlarr', [
      k.ingress.rule(
        'prowlarr.kotee.co',
        [{
          path: '/',
          pathType: 'Prefix',
          backend: k.ingress.service('prowlarr', 'http'),
        }]
      ),
    ])
  ),
])
