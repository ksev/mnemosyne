local k = import 'kubernetes.libsonnet';

local name = 'snabnzb';
local storageName = '%s-storage' % name;

local ports = [
  k.ports.http {
    port: 8080,
  }
];

k.namespace.scope('arr', [
  k.pvc(storageName, '150Mi'),

  k.deployment.create(name, [
    { image: 'lscr.io/linuxserver/sabnzbd:latest' }
    + k.container.ports(ports)
    + k.container.mount(storageName, '/config')
    + k.container.mountNAS('Downloads', '/downloads')
  ])
  + k.deployment.podLabel('vpn', 'proton')
  + k.deployment.volume.pvc(storageName)
  + k.deployment.volume.nas,

  k.service.create(name, ports),
])
