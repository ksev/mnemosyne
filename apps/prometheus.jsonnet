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
  {
    apiVersions: 'v1',
    kind: 'EndPoints',
    metdata: {
      name: 'homey',
      labels: {
        'k8s-app': 'homey',
      },
    },
    subsets: [
      { addresses: '' },
      { ip: '192.168.2.121' },
    ],
    ports: [
      { name: 'name', port: 9414, protocol: 'TCP' },
    ],
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'homey-svc',
      labels: {
        'k8s-app': 'homey',
      },
    },
    spec: {
      type: 'ExternalName',
      externalName: '192.168.2.121',
      clusterIP: '',
      ports: [{ name: 'metrics', port: 9414, protocol: 'TCP', targetPort: 9414 }],
    },
  },
]
