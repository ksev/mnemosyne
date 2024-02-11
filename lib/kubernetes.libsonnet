local namespace = {
  create: function(name) {
    apiVersion: 'v1',
    kind: 'Namespace',
    metadata: {
      name: name,
      labels: {
        name: name,
      },
    },
  },
  scope: function(name, resources, create=false)
    (if create then [namespace.create(name)] else []) + [
      res { metadata+: { namespace: name } }
      for res in resources
    ],
};

local deployment = {
  create: function(name, containers, replicas=1, namespace='default') {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: name,
      namespace: namespace,
      labels: {
        app: name,
      },
    },
    spec: {
      replicas: replicas,
      selector: {
        matchLabels: {
          app: name,
        },
      },
      template: {
        metadata: {
          labels: {
            app: name,
          },
        },
        spec: {
          containers: [
            { name: name } + c
            for c in containers
          ],
        },
      },
    },
  },
  initContainers: function(containers) {
    spec+: {
      template+: {
        spec+: {
          initContainers+: containers,
        },
      },
    },
  },
  volume: {
    hostPath: function(name, path, type='') {
      spec+: {
        template+: {
          spec+: {
            volumes+: [{
              name: name,
              hostPath: {
                type: type,
                path: path,
              },
            }],
          },
        },
      },
    },
    pvc: function(name, readOnly=false) {
      spec+: {
        template+: {
          spec+: {
            volumes+: [{
              name: name,
              persistentVolumeClaim: {
                claimName: name,
                readOnly: readOnly,
              },
            }],
          },
        },
      },
    },
    configMap: function(name, items) {
      spec+: {
        template+: {
          spec+: {
            volumes+: [{
              name: name,
              configMap: {
                name: name,
                items: [
                  { key: item, path: item }
                  for item in items
                ],
              },
            }],
          },
        },
      },
    },
  },
};

local configMap(name, data, namespace='default') = {
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: name,
    namespace: namespace,
  },
  data: data,
};

local container = {
  ports: function(ports) {
    ports+: [
      {
        containerPort: port.port,
        name: port.name,
        protocol: port.protocol,
      }
      for port in ports
    ],
  },
  mount: function(name, path, subPath='') {
    volumeMounts+: [{
      [if std.isEmpty(subPath) then null else 'subPath']: subPath,
      name: name,
      mountPath: path,
    }],
  },

  liveHttp: function(rule, delay=3, period=3){
    livenessProbe: {
      httpGet: rule,
      initialDelaySeconds: delay,
      periodSeconds: period
    },
  }
};

local service = {
  create: function(name, ports, type='ClusterIP') {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: name,
    },
    spec: {
      type: type,
      ports: [
        {
          name: port.name,
          port: port.port,
          protocol: port.protocol,
          targetPort: port.name,
        }
        for port in ports
      ],
      selector: {
        app: name,
      },
    },
  },
  staticIP: function(ip) {
    spec+: {
      loadBalancerIP: ip,
    },
  },
};

local ingress = {
  create: function(name, rules, namespace='default') {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: name,
      namespace: namespace,
    },
    spec: {
      ingressClassName: 'cilium',
      rules: rules,
    },
  },

  rule: function(host, paths) {
    host: host,
    http: {
      paths: paths,
    },
  },

  service: function(name, port) {
    service: {
      name: name,
      port: {
        name: port,
      },
    },
  },

  enableTLS: function(ing)
    assert ing.kind == 'Ingress';
    local hosts = std.map(function(rule) rule.host, ing.spec.rules);
    ing {
      metadata+: {
        annotations+: {
          'cert-manager.io/cluster-issuer': 'letsencrypt-issuer',
        },
      },
      spec+: {
        tls+: [{
          hosts: hosts,
          secretName: '%s-tls' % ing.metadata.name,
        }],
      },
    },
};

local env = {
  item: function(name, value)
    {
      name: name,
    }
    + if std.isObject(value) &&
         std.objectHasAll(value, 'type') then {
      valueFrom: {
        [value.type]: value,
      },
    } else { value: '%s' % value },

  secretValue: {
    type:: 'secretKeyRef',
    name: error 'secret name is needed',
    key: error 'secret key is needed',
  },
};

local pvc(name, storage, accessMode='ReadWriteOnce', namespace='default') = {
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: name,
    namespace: namespace,
  },
  spec: {
    storageClassName: 'local-path',
    accessModes: [accessMode],
    resources: {
      requests: {
        storage: storage,
      },
    },
  },
};

local ports = {
  http: {
    port: 80,
    name: 'http',
    protocol: 'TCP'
  }
};

local busyBox(command) = {
  name: 'busybox',
  image: 'busybox:latest',
  command: ['sh', '-c'],
  args: [command],
};

{
  namespace: namespace,
  deployment: deployment,
  container: container,
  env: env,
  pvc: pvc,
  ports: ports,
  configMap: configMap,
  service: service,
  busyBox: busyBox,
  ingress: ingress,
}
