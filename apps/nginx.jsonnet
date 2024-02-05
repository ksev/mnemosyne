{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: 'ingress-nginx',
    namespace: 'argocd',
  },
  spec: {
    project: 'default',
    source: {
      repoURL: 'https://kubernetes.github.io/ingress-nginx',
      targetRevision: '4.9.1',
      chart: 'ingress-nginx',
      helm: {
        valueObject: {
          'controller.extraArgs.enable-ssl-passthrough': ''
        }
      }
    },
    destination: {
      server: 'https://kubernetes.default.svc',
      namespace: 'ingress-nginx',
    },
    syncPolicy: {
      automated: {
        prune: true,
        selfHeal: true
      },
      syncOptions: [
         'CreateNamespace=true' 
      ]
    }    
  },
}
