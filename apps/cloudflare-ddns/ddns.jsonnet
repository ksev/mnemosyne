local onePassword = import '1password.libsonnet';
local argocd = import 'argocd.libsonnet';
local k = import 'kubernetes.libsonnet';

local name = 'cloudflare-ddns';
local secretName = '%s-token' % name;

k.namespace.scope('pihole', [
  onePassword.item(secretName, 'Cloudflare') 
  + argocd.syncWave(-1),
  
  k.deployment.create(name, [{
    image: 'favonia/cloudflare-ddns:latest', 
    env: [
      k.env.item('PROXIED', false),
      k.env.item('DOMAINS', 'kotee.co'),
      k.env.item('CF_API_TOKEN', k.env.secretValue {
        name: secretName,
        key: 'password',
      }),
    ]
  }])
])
