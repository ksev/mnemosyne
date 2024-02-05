local secretName = 'cloudflare-api-token-secret';

[
  {
    apiVersion: 'onepassword.com/v1',
    kind: 'OnePasswordItem',
    metadata: {
      name: secretName,
      namespace: 'cert-manager',
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
  {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: 'argocd-server-ingress',
      namespace: 'argocd',
      annotations: {
        'nginx.ingress.kubernetes.io/force-ssl-redirect': 'true',
        'nginx.ingress.kubernetes.io/ssl-passthrough': 'true',
        'nginx.ingress.kubernetes.io/backend-protocol': 'HTTPS',
      },
    },
    spec: {
      ingressClassName: 'nginx',
      rules: [{
        host: 'argocd.kotee.co',
        http: {
          paths: [{
            path: '/',
            pathType: 'Prefix',
            backend: {
              service: {
                name: 'argocd-server',
                port: { name: 'https' },
              },
            },
          }],
        },
      }],
      tls: [{
        hosts: ['argocd.kotee.co'],
        secretName: 'argocd-server-tls',
      }],
    },
  },
  {
    apiVersion: 'cilium.io/v2alpha1',
    kind: 'CiliumLoadBalancerIPPool',
    metadata: {
      name: 'lb-pool',
    },
    spec: {
      blocks: [
        {
          start: '192.168.4.6',
          stop: '192.168.4.254',
        },
      ],
    },
  },
  {
    apiVersion: 'cilium.io/v2alpha1',
    kind: 'CiliumL2AnnouncementPolicy',
    metadata: {
      name: 'ann-policy',
    },
    spec: {
      interfaces: [
        'team0',
      ],
      loadBalancerIPs: true,
    },
  },
]
