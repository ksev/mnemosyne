function(public_key) {
	variant: "fcos",
	version: "1.4.0",
	passwd: {
		users: [{
			name: 'kim',
			groups: ['wheel', 'sudo'],
			ssh_authorized_keys: [
				public_key
			]
		}]
	}
}
