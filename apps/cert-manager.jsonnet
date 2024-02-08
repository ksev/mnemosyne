local onePassword = import '1password.libsonnet';
local argocd = import 'argocd.libsonnet';

local secretName = 'cloudflare-api-token-secret';

[
  onePassword.item('Cloudflare', secretName, namespace='cert-manager'),
  argocd.appHelm(
    'cert-manager',
    'https://charts.jetstack.io',
    revision='1.14.1',
    namespace='cert-manager',
    values={
      installCRDs: true,
      prometheus: {
        enabled: true,
        servicemonitor: {
          enabled: true,
        },
      },
    }
  ) + argocd.syncWave(-1),
  {
    apiVersion: 'cert-manager.io/v1',
    kind: 'ClusterIssuer',
    metadata: {
      name: 'letsencrypt-issuer',
      namespace: 'cert-manager',
    },
    spec: {
      acme: {
        email: 'something@kotee.co',
        server: 'https://acme-v02.api.letsencrypt.org/directory',
        privateKeySecretRef: {
          name: 'acme-issuer-account-key',
        },
        solvers: [{
          dns01: {
            cloudflare: {
              apiTokenSecretRef: {
                name: secretName,
                key: 'password',
              },
            },
          },
        }],
      },
    },
  },
  {
    apiVersion: 'cert-manager.io/v1',
    kind: 'Certificate',
    metadata: {
      name: 'argocd-ui-cert',
      namespace: 'argocd',
    },
    spec: {
      secretName: 'argocd-server-tls',
      dnsNames: [
        'argocd.kotee.co',
      ],
      issuerRef: {
        name: 'letsencrypt-issuer',
        kind: 'ClusterIssuer',
      },
    },
  },
  {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: 'argocd-server-ingress',
      namespace: 'argocd',
      annotations: {
        'ingress.cilium.io/tls-passthrough': 'enabled',
      },
    },
    spec: {
      ingressClassName: 'cilium',
      rules: [{
        host: 'argocd.kotee.co',
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'argocd-server',
                  port: {
                    name: 'https',
                  },
                },
              },
            },
          ],
        },
      }],
      tls: [
        {
          hosts: ['argocd.kotee.co'],
          secretName: 'argocd-server-tls',
        },
      ],
    },
  },
]
