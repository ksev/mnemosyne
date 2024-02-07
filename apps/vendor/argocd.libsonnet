local appFolder = function(name) {
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: name,
    namespace: 'argocd',
  },
  spec: {
    project: 'default',
    directory: {
      include: './%s/*.jsonnet',
    },
    destination: {
      server: 'https://kubernetes.default.svc',
      namespace: 'default'
    },
    syncPolicy: {
      automated: {
        prune: true,
        selfHeal: true,
      },
      syncOptions: ['CreateNamespace=true'],
    },
  },
};

{
  appFolder: appFolder,
}
