local domain = 'kotee.co';

local devices = [{
  name: 'render',
  paths: ['/dev/dri/renderD128'],
}];

local name = 'generic-device-plugin';

{
  apiVersion: 'apps/v1',
  kind: 'DaemonSet',
  metadata: {
    name: name,
    namespace: 'kube-system',
    labels: {
      'app.kubernetes.io/name': name,
    },
  },
  spec: {
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': name,
      },
    },
    updateStrategy: {
      type: 'RollingUpdate',
    },
    template: {
      metadata: {
        labels: {
          'app.kubernetes.io/name': name,
        },
      },
      spec: {
        priorityClassName: 'system-node-critical',
        tolerations: [
          { operator: 'Exists', effect: 'NoExecute' },
          { operator: 'Exists', effect: 'NoSchedule' },
        ],
        containers: [{
          name: name,
          image: 'squat/generic-device-plugin:latest',
          args: ['--domain', domain] + std.flattenArrays([
            [
              '--device',
              std.manifestJsonMinified({
                name: dev.name,
                groups: [{
                  paths: [
                    {path: path}
                    for path in dev.paths
                  ]
                }]
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
          ports: [{
            containerPort: 8080,
            name: 'http',
          }],
          securityContext: {
            privileged: true,
          },
          volumeMounts: [
            {
              name: 'device-plugin',
              mountPath: '/var/lib/kubelet/device-plugins',
            },
            {
              name: 'dev',
              mountPath: '/dev',
            },
          ],
        }],
        volumes: [
          { name: 'device-plugin', hostPath: { path: '/var/lib/kubelet/device-plugins' } },
          { name: 'dev', hostPath: { path: '/dev' } },
        ],
      },
    },
  },
}
