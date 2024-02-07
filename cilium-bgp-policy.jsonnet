{
  apiVersion: 'cilium.io/v2alpha1',
  kind: 'CiliumBGPPeeringPolicy',
  metadata: {
    name: '01-bgp-peering-policy',
  },
  spec: {
    virtualRouters: [
      {
        localASN: 64512,
        neighbors: [
          {
            peerAddress: '192.168.1.1/32',
            peerASN: 64512,
          },
        ],
      },
    ],
  },
}
