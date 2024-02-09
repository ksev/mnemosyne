local onePassword = import '1password.libsonnet';
local argocd = import 'argocd.libsonnet';

local env(name, value) =
  {
    name: name,
  }
  + if std.isObject(value) &&
       std.objectHasAll(value, 'type') then {
    valueFrom: {
      [value.type]: value,
    },
  } else { value: '%s' % value };

local secretValue = {
  type:: 'secretKeyRef',
  name: error 'secret name is needed',
  key: error 'secret key is needed',
};

local name = 'cloudflare-ddns';
local secretName = '%s-token' % name;

[
  onePassword.item('Cloudflare', secretName, namespace='cert-manager') + argocd.syncWave(-1),
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
                name: secretName,
                key: 'password',
              }),
            ],
          }],
        },
      },
    },
  },
]
