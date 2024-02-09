local name = 'cloudflare-ddns';

local env(name, value) =
  {
    name: name,
  }
  + if std.isObject(value) &&
       std.objectHasAll(value, 'type') then {
    valueFrom: {
      [value.type]: value,
    },
  } else { value: value };

local envSecretValue(name, secretName, key) = {
  name: name,
  valueFrom: {
    secretKeyRef: {
      name: secretName,
      key: key,
    },
  },
};

local secretValue = {
  type:: 'secretKeyRef',
  name: error 'secret name is needed',
  key: error 'secret key is needed',
};

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: '%s-deployment' % name,
    namespace: 'pihole',
  },
  spec: {
    replicas: 1,
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
        containers: [{
          name: name,
          image: 'favonia/cloudflare-ddns:latest',
          env: [
            env('PROXIED', false),
            env('DOMAINS', 'kotee.co'),
            env('CF_API_TOKEN', secretValue {
              name: 'cloudflare-api-token-secret',
              key: 'password',
            }),
          ],
        }],
      },
    },
  },
}
