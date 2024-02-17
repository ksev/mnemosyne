local k = import 'kubernetes.libsonnet';

local name = 'jellyfin';
local storageName = '%s-storage' % name;
local cacheName = '%s-cache' % name;

local ports = [{
  port: 8096,
  name: 'jelly',
  protocol: 'TCP',
}];

k.namespace.scope('arr', [
  k.pvc(storageName, '150Mi'),
  k.pvc(cacheName, '5Gi'),

  k.deployment.create(name, [
    { image: 'jellyfin/jellyfin' }
    + k.container.ports(ports)
    + k.container.mount(storageName, '/config')
    + k.container.mount(cacheName, '/cache')
    + k.container.mountNAS('Media', '/media'),
  ])
  + k.deployment.volume.pvc(storageName)
  + k.deployment.volume.pvc(cacheName)
  + k.deployment.volume.nas,

  k.service.create(name, ports, type='LoadBalancer')
  + k.service.staticIP('10.50.1.50'),
])
