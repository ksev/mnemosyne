local ns(name) = {
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: name,
    labels: {
      name: name,
    },
  },
};

local scoped(name, resources, create=false) =
  (if create then [ns(name)] else []) + [
    res { metadata+: { namespace: name } }
    for res in resources
  ];

local deployment(name, containers, replicas=1, namespace='default') = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: '%s-deployment' % name,
    namespace: namespace,
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

local volume = {
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
};

local containerMount = {
  configMap: function(name, key, path) {
    volumeMounts+: [{
      name: name,
      mountPath: path,
      subKey: key,
    }],
  },
};

local container = {
  ports: function(ports) {
    ports+: [
      { containerPort: port }
      for port in ports
    ],
  },
  mount: containerMount,
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
  env: env,
  ns: ns,
  scoped: scoped,
  deployment: deployment,
  container: container,
  configMap: configMap,
  volume: volume,
}
