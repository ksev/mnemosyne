[
  {
    apiVersion: 'argoproj.io/v1alpha1',
    kind: 'Application',
    metadata: {
      name: 'prometheus',
      namespace: 'argocd',
    },
    spec: {
      project: 'default',
      source: {
        repoURL: 'https://prometheus-community.github.io/helm-charts',
        targetRevision: '56.6.1',
        chart: 'kube-prometheus-stack',
        helm: {
          valuesObject: {
            grafana: {
              ingress: {
                enabled: true,
                ingressClassName: 'cilium',
                annotations: {
                  'cert-manager.io/cluster-issuer': 'letsencrypt-issuer'
                },
                hosts: ['grafana.kotee.co'],
                tls: [{
                  hosts: ['grafana.kotee.co'],
                  secretName: 'grafana-tls'
                }]
              }
            },
            prometheus: {
              prometheusSpec: {
                additionalScrapeConfigs: [{
                  job_name: 'homey',
                  scheme: 'http',
                  metrics_path: '/metrics',
                  static_configs: [
                    {targets: ['192.168.2.121:9414']},
                  ],
                }],
              },
            },
          },
        },
      },
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: 'prometheus',
      },
      syncPolicy: {
        automated: {
          prune: true,
          selfHeal: true,
        },
        syncOptions: [
          'CreateNamespace=true',
          'ServerSideApply=true',
        ],
      },
    },
  },
]
