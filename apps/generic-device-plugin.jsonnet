local k = import 'kubernetes.libsonnet';

local domain = 'kotee.co';

local ports = [
  k.ports.http {
    port: 8080,
  },
];

local devices = [{
  name: 'render',
  limit: 10,
  paths: ['/dev/dri/renderD128'],
}];

local name = 'generic-device-plugin';

k.deployment.createDS(
  name,
  [
    {
      image: 'squat/generic-device-plugin:latest',
      args: ['--domain', domain] + std.flattenArrays([
        [
          '--device',
          std.manifestJsonMinified({
            name: dev.name,
            groups: [{
              limit: dev.limit,
              paths: [
                { path: path }
                for path in dev.paths
              ],
            }],
          }),
        ]
        for dev in devices
      ]),
      resources: {
        requests: {
          cpu: '50m',
          memory: '10Mi',
        },
        limits: {
          cpu: '50m',
          memory: '20Mi',
        },
      },
      securityContext: {
        privileged: true,
      },
    }
    + k.container.ports(ports)
    + k.container.mount('device-plugin', '/var/lib/kubelet/device-plugins')
    + k.container.mount('dev', '/dev'),
  ],
  [
    { operator: 'Exists', effect: 'NoExecute' },
    { operator: 'Exists', effect: 'NoSchedule' },
  ],
  priorityClass='system-node-critical',
  namespace='kube-system'
)
+ k.deployment.volume.hostPath('device-plugin', '/var/lib/kubelet/device-plugins')
+ k.deployment.volume.hostPath('dev', '/dev')
