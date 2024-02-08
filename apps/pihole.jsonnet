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

argocd.appHelm(
  'pi-hole',
  'https://mojo2600.github.io/pihole-kubernetes/',
  'pihole',
  revision='2.21.0',
  values={
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
    ingress: {
      enabled: true,
      ingressClassName: 'cilium',
      annotations: {
        'cert-manager.io/cluster-issuer': 'letsencrypt-issuer',
      },
      hosts: [],
      tls: [{
        hosts: [],
        secretName: 'pihole-tls',
      }],
    },
  }
)
