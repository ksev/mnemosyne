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
  mount: function(name, path, subPath='', readOnly=true) {
    volumeMounts+: [{
      [if std.isEmpty(subPath) then null else 'subPath']: subPath,
      name: name,
      mountPath: path,
      readOnly: readOnly,
    }],
  },
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


{
  namespace: namespace,
  deployment: deployment,
  container: container,
  env: env,
  configMap: configMap,
  service: service,
}
