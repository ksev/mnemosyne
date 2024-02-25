local k = import 'kubernetes.libsonnet';

local name = 'jellyfin';
local storageName = '%s-storage' % name;

local ports = [
  k.ports.http {
    port: 8096
  }
];

k.namespace.scope('arr', [
  k.pvc(storageName, '150Mi'),

  k.deployment.create(name, [
    { 
      image: 'linuxserver/jellyfin:latest',
      resources: {
        limits: {
           'kotee.co/render': 1 
        }        
      },
      env: [
        k.env.item('DOCKER_MODS', 'linuxserver/mods:jellyfin-opencl-intel')
      ]
    }
    + k.container.ports(ports)
    + k.container.mount(storageName, '/config')
    + k.container.mountNAS('Media', '/media')
  ])
  + k.deployment.volume.pvc(storageName)
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
