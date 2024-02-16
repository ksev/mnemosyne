local onePassword = import '1password.libsonnet';
local k = import 'kubernetes.libsonnet';


local name = 'transmission';
local storageName = '%s-storage' % name;
local secret = '%s-login' % name;

local ports = [
  k.ports.http {
    port: 9091,
  },
  {
    name: 'bt-tcp',
    port: 51413,
    protocol: 'TCP',
  },
  {
    name: 'bt-udp',
    port: 51413,
    protocol: 'UDP',
  },
];

k.namespace.scope('arr', [
  k.pvc(storageName, '150Mi'),

  onePassword.item(secret, 'Transmission'),

  k.deployment.create(name, [
    {
      image: 'lscr.io/linuxserver/transmission:latest',
      env: [
        k.env.item('USER', k.env.secretValue {
          name: secret,
          key: 'username',
        }),
        k.env.item('PASS', k.env.secretValue {
          name: secret,
          key: 'password',
        }),
      ],
    }
    + k.container.ports(ports)
    + k.container.mount(storageName, '/config')
    + k.container.mount(
      'nas',
      '/downloads',
    ),
  ])
  + k.deployment.volume.pvc(storageName)
  + k.deployment.volume.nfs(
    'nas',
    '192.168.1.62',
    '/Downloads/'
  ),

  k.service.create(name, ports, type='LoadBalancer'),
])
