local k = import 'kubernetes.libsonnet';

local name = 'sonarr';
local storageName = '%s-storage' % name;

local ports = [
  k.ports.http {
    port: 8989,
  },
];

k.namespace.scope('arr', [
  k.pvc(storageName, '150Mi'),

  k.deployment.create(name, [
    { image: 'lscr.io/linuxserver/sonarr:latest' }
    + k.container.ports(ports)
    + k.container.mount(storageName, '/config')
    + k.container.mountNAS('/downloads', 'Downloads')
    + k.container.mountNAS('/tv', 'Media/tv'),
  ])
  + k.deployment.volume.pvc(storageName)
  + k.deployment.volume.nas,

  k.service.create(name, ports),

  k.ingress.enableTLS(
    k.ingress.create(name, [
      k.ingress.rule(
        'sonarr.kotee.co',
        [{
          path: '/',
          pathType: 'Prefix',
          backend: k.ingress.service(name, 'http'),
        }]
      ),
    ])
  ),
])
