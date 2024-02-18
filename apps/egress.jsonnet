{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumEgressGatewayPolicy',
  metadata: {
    name: 'vpn-egress',
  },
  spec: {
    selectors: [{
      podSelector: {
        matchLabels: {
          vpn: 'proton',
        },
      },
    }],
    egressGateway: {
      nodeSelector: {
        matchLabels: {
          'kubernetes.io/hostname': 'mnemosyne'
        },
      },
      interface: 'team0.5'
    },
    destinationCIDRs: [
      '0.0.0.0/0',
    ],
    excludedCIDRs: [
      '127.0.0.0/8',
      '10.0.0.0/8',
      '192.168.0.0/16',
    ],
  },
}
