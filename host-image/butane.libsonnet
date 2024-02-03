local butaneFiles = function(files) {
  storage+: {
    files+: files,
  },
};

local bootMirror = function(devs) {
  boot_device: {
    mirror: {
      devices: devs,
    },
  },
};

local user = function(name, groups, publicKey, password_hash='') {
  passwd+: {
    users+: [
      {
        name: name,
        groups: groups,
        ssh_authorized_keys: [
          publicKey,
        ],
      } +
      if std.isEmpty(password_hash) then {}
      else { password_hash: password_hash },
    ],
  },
};

local partition = function(dev, partitions) {
  storage+: {
    disks+: [
      {
        device: dev,
        partitions: [
          {
            label: p.label,
            [if std.objectHas(p, 'size_mb') then 'size_mb']: p.size_mb,
          }
          for p in partitions
        ],
      },

    ],
  },
};

local raid1 = function(name, devices) {
  storage+: {
    raid+: [{
      name: name,
      level: 'raid1',
      devices: [
        '/dev/disk/by-partlabel/%s' % device
        for device in devices
      ],
    }],
  },
};

local filesystem = function(dev, path, format='xfs', wipe_filesystem=false, with_mount_unit=true) {
  storage+: {
    filesystems+: [{
      device: dev,
      path: path,
      format: format,
      wipe_filesystem: wipe_filesystem,
      with_mount_unit: with_mount_unit 
    }]
  }
};

local networkTeam = function(name, ifaces)
  local fileName = function(name)
    '/etc/NetworkManager/system-connections/%s.nmconnection' % name;

  local teamUnit = std.manifestIni({
    sections: {
      connection: {
        id: name,
        type: 'team',
        'interface-name': name,
      },
      team: {
        config: { runner: { name: 'lacp' }, link_watch: { name: 'ethtool' } },
      },
      ipv4: {
        'dns-search': '',
        'may-fail': false,
        method: 'auto',
      },
    },
  });

  local slaveUnit = function(iface) std.manifestIni({
    sections: {
      connection: {
        id: '%s-slave-%s' % [name, iface],
        type: 'ethernet',
        'interface-name': iface,
        master: name,
        'slave-type': 'team',
      },
      'team-port': {
        config: { prio: 100 },
      },
    },
  });

  butaneFiles(
    [
      {
        path: fileName(name),
        mode: std.parseOctal('0600'),
        contents: { inline: teamUnit },
      },
    ]
    +
    [
      {
        path: fileName('%s-slave-%s' % [name, iface]),
        mode: std.parseOctal('0600'),
        contents: { inline: slaveUnit(iface) },
      }
      for iface in ifaces
    ]
  );

{
  fcos14: {
    variant: 'fcos',
    version: '1.4.0',
  },
  networkTeam: networkTeam,
  bootMirror: bootMirror,
  user: user,
  partition: partition,
  raid1: raid1,
  filesystem: filesystem
}
