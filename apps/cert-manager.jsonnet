local secretName = 'cloudflare-api-token-secret';

[
  {
    apiVersion: 'onepassword.com/v1',
    kind: 'OnePasswordItem',
    metadata: {
      name: secretName,
      namespace: 'cert-manager',
      annotations: {
        'argocd.argoproj.io/sync-wave': "-1",
      }
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
      annotations: {
        'argocd.argoproj.io/sync-wave': "-1",
      }
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
                enabled: true,
              },
            },
          },
        },
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
]
