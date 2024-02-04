{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: 'root',
    namespace: 'argocd'
  },
  spec: {
    project: 'default',
    source: {
      repoURL: 'https://github.com/ksev/mnemosyne.git',
      targetRevision: 'HEAD',
      path: 'apps'
    },
    destination: {
      server: 'https://kubernetes.default.svc',
      namespace: 'default'
    }    
  }
}
