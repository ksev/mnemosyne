local appFolder = function(name, path) {
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
        jsonnet: {
          libs: ['vendor', 'lib'],
        },
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

local serverSideApply = {
  spec+: {
    syncPolicy+: {
      syncOptions+: [
        'ServerSideApply=true',
      ],
    },
  },
};

local appHelm = function(name, repo, chart, revision='HEAD', namespace='default', values={}) {
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: name,
    namespace: 'argocd',
  },
  spec: {
    project: 'default',
    source: {
      repoURL: repo,
      targetRevision: revision,
      chart: chart,
      helm: {
        values: std.manifestYamlDoc(values),
      },
    },
    destination: {
      server: 'https://kubernetes.default.svc',
      namespace: namespace,
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
};

{
  appFolder: appFolder,
  appHelm: appHelm,
  serverSideApply: serverSideApply
}
