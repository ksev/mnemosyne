local k = import 'kubernetes.libsonnet';

local name = 'jellyfin';
local storageName = '%s-storage' % name;
local cacheName = '%s-cache' % name;

local ports = [
  k.ports.http {
    port: 8096
  }
];

k.namespace.scope('arr', [
  k.pvc(storageName, '150Mi'),
  k.pvc(cacheName, '5Gi'),

  k.deployment.create(name, [
    { image: 'jellyfin/jellyfin' }
    + k.container.ports(ports)
    + k.container.mount(storageName, '/config')
    + k.container.mount(cacheName, '/cache')
    + k.container.mountNAS('Media', '/media')
    + k.container.liveHttp({
      path: '/health',
      port: 8096,
    }),
  ])
  + k.deployment.volume.pvc(storageName)
  + k.deployment.volume.pvc(cacheName)
  + k.deployment.volume.nas,

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
