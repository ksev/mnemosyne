local k = import 'kubernetes.libsonnet';

local name = 'transmission';
local storageName = '%s-storage' % name;

local ports = [
  k.ports.http {
    port: 9091,
  },
  { 
    name: 'bt-tcp',
    port: 51413,
    protocol: 'TCP'
  },
  { 
    name: 'bt-udp',
    port: 51413,
    protocol: 'UDP'
  }
];

k.namespace.scope('arr', [
  k.pvc(storageName, '150Mi'),

  k.deployment.create(name, [
    { image: 'lscr.io/linuxserver/transmission:latest' }
    + k.container.ports(ports)
    + k.container.mount(storageName, '/config') 
    + k.container.mount(
      'abc123', 
      '/downloads', 
      subPath='Downloads/torrent/'
    ) 
  ])
  + k.deployment.volume.pvc(storageName)
  + k.deployment.volume.nfs(
    'abc123',
    '192.168.1.62',
    '/'
  ),

  k.service.create(name, ports),
])
