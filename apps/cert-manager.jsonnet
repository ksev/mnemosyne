local secretName = 'cloudflare-api-token-secret';

[
  {
    apiVersion: 'onepassword.com/v1',
    kind: 'OnePasswordItem',
    metadata: {
      name: secretName,
    },
    spec: {
      itemPath: 'vaults/Homeserver/items/Cloudflare',
    },
  },
  {
    apiVersion: 'argoproj.io/v1alpha1',
    kind: 'Application',
    metadata: {
      name: 'cert-manager',
      namespace: 'argocd',
    },
    spec: {
      project: 'default',
      source: {
        repoURL: 'https://charts.jetstack.io',
        targetRevision: '1.14.1',
        chart: 'cert-manager',
        helm: {
          valuesObject: {
            installCRDs: true,
            prometheus: {
              enabled: true,
              serviceMonitor: {
                enabled: true
              }
            },
            extraArgs: {
              'feature-gates': 'ExperimentalGatewayAPISupport=true'
            }
          }
        }
      },
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: 'cert-manager',
      },
      syncPolicy: {
        automated: {
          prune: true,
          selfHeal: true,
        },
        syncOptions: [
          'CreateNamespace=true',
        ],
      },
    },
  },
  {
    apiVersion: 'cert-manager.io/v1',
    kind: 'Issuer',
    metadata: {
      name: 'acme-issuer',
      namespace: 'cert-manager',
    },
    spec: {
      acme: {
        email: 'something@kotee.co',
        server: 'https://acme-v02.api.letsencrypt.org/directory',
        privateKeySecretRef: {
          name: 'acme-issuer-account-key'
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
]
