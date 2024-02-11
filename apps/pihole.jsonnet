local onePassword = import '1password.libsonnet';
local argocd = import 'argocd.libsonnet';
local k = import 'kubernetes.libsonnet';

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
    revision='2.21.0',
    namespace='pihole',
    values={
      DNS1: "1.1.1.1",
      DNS2: "1.0.0.1",
      podDnsConfig: {
        nameservers: [
          '127.0.0.1',
          '1.1.1.1'
        ]
      },
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
      adlists: blocklists,
    }
  ),

  k.ingress.enableTLS(
    k.ingress.create('pihole', [
      k.ingress.rule(
        'pihole.kotee.co',
        [{
          path: '/',
          pathType: 'Prefix',
          backend: k.ingress.service('pihole-web', 'http'),
        }]
      ),
    ], namespace='pihole')
  ),
]
