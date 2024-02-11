local k = import 'kubernetes.libsonnet';

local storageName = 'prowlarr-storage';

k.namespace.scope('arr',[
  k.pvc(storageName, '5Gi'),

  k.deployment.create('prowlarr', [
    { image: 'lscr.io/linuxserver/prowlarr:latest' }
    + k.container.ports([{
      name: 'http',
      port: 9696,
      protocol: 'TCP'
    }])
    + k.container.mount(storageName, '/config')
  ])
  + k.deployment.volume.pvc(storageName)
])
