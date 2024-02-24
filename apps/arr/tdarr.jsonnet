local k = import 'kubernetes.libsonnet';

local ports = [
	k.ports.http {
		port: 8265,
	}
];

local name = 'tdarr';
local storageName = '%s-storage' % name;

k.namespace.scope('arr', [
  k.pvc(storageName, '300Mi'),

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
		+ k.container.mount(storageName, '/app')
		+ k.container.mountNAS('Media', '/media')
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
