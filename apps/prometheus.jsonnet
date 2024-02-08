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
            prometheusOperator: {
              prometheus: {
                prometheusSpec: {
                  additionalScrapeConfigs: [{
                    jobName: 'homey',
                    scheme: 'http',
                    metrics_path: '/metrics',
                    static_configs: [
                      '192.168.2.121:9414',
                    ],
                  }],
                },
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
