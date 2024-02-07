local appFolder = function(path, name) {
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: name,
    namespace: 'argocd',
  },
  spec: {
    project: 'default',
    source: {
      repoURL: 'https://github.com/ksev/mnemosyne.git',
      targetRevision: 'HEAD',
      path: path,
      directory: {
        libs: ['vendor', 'lib'],
      },
    },

    destination: {
      server: 'https://kubernetes.default.svc',
      namespace: 'default',
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
