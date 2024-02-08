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
      serviceWeb: {
        https: {
          enabled: false
        }
      },
      serviceDhcp: {
        enabled: false,
      },
      adlist: blocklists,
      virtualHost: 'pihole.kotee.co',
      path: '/admin/',
      ingress: {
        enabled: true,
        ingressClassName: 'cilium',
        annotations: {
          'cert-manager.io/cluster-issuer': 'letsencrypt-issuer',
        },
        hosts: ['pihole.kotee.co'],
        tls: [{
          hosts: ['pihole.kotee.co'],
          secretName: 'pihole-tls',
        }],
      },
    }
  ),
]
