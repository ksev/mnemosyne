local onePassword = import '1password.libsonnet';
local argocd = import 'argocd.libsonnet';

local blocklists = [
  'https://blocklistproject.github.io/Lists/%s.txt' % list
  for list in [
    'abuse',
    'ads',
    'malware',
    'ransomware',
    'scam',
    'tracking',
    'smart-tv',
  ]
];

local secretKey = 'pihole-admin-secret';

[
  onePassword.item('PiHole Admin', secretKey, namespace='pihole'),
  argocd.appHelm(
    'pihole',
    'https://mojo2600.github.io/pihole-kubernetes/',
    'pihole',
    revision='2.21.0',
    namespace='pihole',
    values={
      admin: {
        existingSecret: secretKey,
        passwordKey: 'password',
      },
      serviceDns: {
        mixedService: true,
        loadBalancerIP: '10.50.1.1',
        type: 'LoadBalancer',
      },
      serviceDhcp: {
        enabled: false,
      },
      virtualHost: 'pihole.kotee.co',
      adlist: blocklists,
    }
  ),
  {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      annotations: {
        'cert-manager.io/cluster-issuer': 'letsencrypt-issuer',
      },
      name: 'pihole',
      namespace: 'pihole',
    },
    spec: {
      ingressClassName: 'cilium',
      rules: [{
        host: 'pihole.kotee.co',
        http: {
          paths: [{
            backend: {
              service: {
                name: 'pihole-web',
                port: {
                  name: 'http',
                },
              },
              path: '/',
              pathType: 'Prefix',

            },
          }],
        },
      }],
      tls: [{
        hosts: ['pihole.kotee.co'],
        secretName: 'pihole-tls',
      }],
    },
  },
]
