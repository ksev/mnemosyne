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

local keyMap = function(lang)
  butaneFiles([{
    path: '/etc/vconsole.conf',
    mode: std.parseOctal('0644'),
    contents: { inline: 'KEYMAP=%s' % lang }
  }]);

local rebase = function(image) {
  systemd+: {
    units+: [{
      name: 'rebase-image.service',
      enabled: true,
      contents: std.manifestIni({
        sections: {
          Unit: {
            Description: 'Fetch and deploy rebase image',
            ConditionFirstBoot: true,
            After: 'network-online.target'
          }, 
          Service: {
            After: 'ignition-firstboot-complete.service',
            Type: 'oneshot',
            RemainAfmterExit: 'yes',
            ExecStart: 'rpm-ostree --bypass-driver rebase --reboot ostree-unverified-registry:%s' % image
          },
          Install: {
            WantedBy: 'multi-user.target'
          }
        }
      }) 
    }]
  }
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
            [if std.objectHas(p, 'size_mib') then 'size_mib']: p.size_mib,
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

local vlan = function(iface, vlanId) 
  local devName = '%s.%d' % [iface, vlanId];
  local vlanUnit = std.manifestIni({
    sections: {
      connection: {
        id: devName,
        type: 'vlan',
        'interface-name': devName,        
      },
      vlan: {
        'egress-priority-map': '',
        'ingress-priority-map': '',
        flags: 1,
        id: vlanId,
        parent: iface
      },
      ipv4: {
        'dns-seach': '',
        'may-fail': false,
        method: 'auto'
      }
    }  
  });
  butaneFiles([{
    path: '/etc/NetworkManager/system-connections/%s.nmconnection' % devName,
    mode: std.parseOctal('0600'),
    contents: { inline: vlanUnit }
  }]);
  

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
  fcos15: {
    variant: 'fcos',
    version: '1.5.0',
  },
  networkTeam: networkTeam,
  bootMirror: bootMirror,
  user: user,
  partition: partition,
  raid1: raid1,
  filesystem: filesystem,
  vlan: vlan,
  keyMap: keyMap,
  rebase: rebase
}
