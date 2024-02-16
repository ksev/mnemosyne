{
	apiVersion: 'cilium.io/v2',
	kind: 'CiliumEgressGatewayPolicy',
	metadata: {
		metadata: {
			  name: 'vpn-egress'
		}
	},
	spec: {
		selectors: [{
			podSelector: {
				matchLabels: {
					vpn: 'proton'
				}
			}
		}],
		egressGateway: {
			nodeSelector: {
				matchLabels: {
					 'node.kubernetes.io/name': 'localhost.localdomain'
				}
			}
		},
		interface: 'team0.5'
	},
}
