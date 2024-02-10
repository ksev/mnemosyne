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

local container = {
  ports: function(ports) {
    ports+: [
      { containerPort: port }
      for port in ports
    ],
  },
};

{
  env: env,
  ns: ns,
  deployment: deployment,
  container: container,
}
