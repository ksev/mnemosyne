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
    + k.container.mountNAS('Downloads', '/downloads')
  ])
  + k.deployment.podLabel('vpn', 'proton')
  + k.deployment.volume.pvc(storageName)
  + k.deployment.volume.nas,

  k.service.create(name, ports, type='LoadBalancer')
  + k.service.staticIP('10.50.1.4'),
])
