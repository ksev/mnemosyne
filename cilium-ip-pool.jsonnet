{
  apiVersion: 'cilium.io/v2alpha1',
  kind: 'CiliumLoadBalancerIPPool',
  metadata: {
    name: 'lb-pool',
  },
  spec: {
    cidrs: [
      { cidr: '10.50.0.0/16' },
    ],
  },
}
