local b = import '../butane.libsonnet';

local nvme = [
  '/dev/nvme0n1',
  '/dev/nvme1n1',
];

local ifaces = [
  'enp6s0', 
  'enp6s0d1'
];

function(publicKey)
  b.fcos15 +
  b.rebase('ghcr.io/ksev/ostree-images/k3s-node:latest') + 
  b.networkTeam('team0', ifaces) +
  b.vlan('team0', 1) +
  b.vlan('team0', 5) +
  b.bootMirror(nvme) +
  b.partition(
    nvme[0],
    [
      { label: 'root-1', size_mib: 16384 },
      { label: 'var-1' },
    ]
  ) +
  b.partition(
    nvme[1],
    [
      { label: 'root-2', size_mib: 16384 },
      { label: 'var-2' },
    ]
  ) +
  b.raid1('md-var', ['var-1', 'var-2']) +
  b.filesystem('/dev/md/md-var', '/var') +
  b.keyMap('se') +
  b.user(
    'kim',
    ['wheel', 'sudo'],
    publicKey,
    password_hash='$y$j9T$CKGpHzwkfHnWQBhFvYNNT0$iLSrA9D9U7Oubex.VpRs8yQuOs1OspwAlgZwI3VJFrA'
  )
