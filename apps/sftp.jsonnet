local k = import 'kubernetes.libsonnet';

local name = 'sftp';
local storageName = '%s-storage' % name;
local configName = '%s-config' % name;
local configFile = 'sftp.json';

local ports = [
    {
        port: 22,
        name: 'sftp',
        protocol: 'TCP'
    }
];

k.namespace.scope('sftp', [
  k.configMap(configName, {
    [configFile]: std.manifestJsonMinified({
        "Global": {
            "Chroot": {
                "Directory": "/vault",
                "StartPath": "tom"
            },
            "Directories": ["tom"]
        },
        "Users": [
            {
                "Username": "tom",
                "Password": "CMccPAAJbv7gP7YV2MK79VQjhWBh"
            }
        ]
    }),
  }),

  k.deployment.create(name, [
    {
      image: 'emberstack/sftp:latest',
    }
    + k.container.ports(ports)
    + k.container.mount(configName, '/app/config//%s' % configFile, subPath=configFile)
    + k.container.mountNAS('Vault', '/vault')
  ])
  + k.deployment.volume.configMap(configName, [configFile])
  + k.deployment.volume.nas,

  k.service.create(name, ports, type='LoadBalancer')
  + k.service.staticIP('10.50.1.89')
], create=true)
