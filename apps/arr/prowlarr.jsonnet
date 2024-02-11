local onePassword = import '1password.libsonnet';
local k = import 'kubernetes.libsonnet';

local storageName = 'prowlarr-storage';
local ports = [
  k.ports.http {
    port: 9696,
  },
];

k.namespace.scope('arr', [
  onePassword.item('prowlarr-secret', 'Prowlarr'),

  k.pvc(storageName, '5Gi'),

  k.deployment.create('prowlarr', [
    { image: 'lscr.io/linuxserver/prowlarr:latest' }
    + k.container.ports(ports)
    + k.container.mount(storageName, '/config')
    + k.container.liveHttp({
      path: '/api/v1/health',
      port: 9696,
      httpHeaders: [{
        name: 'X-Api-Key',
        valueFrom: {
          secretKeyRef: {
            name: 'prowlarr-secret',
            key: 'apiKey',
          },
        },
      }],
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
