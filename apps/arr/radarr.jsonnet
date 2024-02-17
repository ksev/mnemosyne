local k = import 'kubernetes.libsonnet';

local name = 'radarr';
local storageName = '%s-storage' % name;

local ports = [
  k.ports.http {
    port: 7878,
  },
];

k.namespace.scope('arr', [
  k.pvc(storageName, '150Mi'),

  k.deployment.create(name, [
    { image: 'linuxserver/radarr:latest' }
    + k.container.ports(ports)
    + k.container.mount(storageName, '/config')
    + k.container.mountNAS('Downloads', '/downloads')
    + k.container.mountNAS('Media/movies', '/movies'),
  ])
  + k.deployment.volume.pvc(storageName)
  + k.deployment.volume.nas,

  /*
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
  */
])
