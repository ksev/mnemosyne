local k = import 'kubernetes.libsonnet';

local ports = [
	k.ports.http {
		port: 8265,
	}
];

local name = 'tdarr';
local storageConfig = '%s-config' % name;
local storageServer = '%s-server' % name;
local storageLogs = '%s-logs' % name;
local transcodeCache = '%s-cache' % name;

k.namespace.scope('arr', [
  k.pvc(storageConfig, '300Mi'),
  k.pvc(storageServer, '300Mi'),
  k.pvc(storageLogs, '300Mi'),
  k.pvc(transcodeCache, '100Gi'),

	k.deployment.create(name, [
		{ 
			image: 'ghcr.io/haveagitgat/tdarr',
			env: [
				k.env.item("serverIP", "0.0.0.0"),
				k.env.item("webUIPort", 8265),
				k.env.item("internalNode", true),
				k.env.item("inContainer", true),
				k.env.item("ffmpegVersion", 6),
				k.env.item("nodeName", "InternalNode")
			]
		}
		+ k.container.ports(ports)
		+ k.container.mount(storageConfig, '/app/configs')
		+ k.container.mount(storageServer, '/app/server')
		+ k.container.mount(storageLogs, '/app/logs')
		+ k.container.mount(transcodeCache, '/temp')
		+ k.container.mountNAS('Media', '/media')
	])
	+ k.deployment.volume.pvc(storageConfig)
	+ k.deployment.volume.pvc(storageServer)
	+ k.deployment.volume.pvc(storageLogs)
	+ k.deployment.volume.pvc(transcodeCache)
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
