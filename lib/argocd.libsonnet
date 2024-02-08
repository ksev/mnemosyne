local app(name) = {
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: name,
    namespace: 'argocd',
  },
  spec: {},
};

local appFolder(name, path) =
  app(name) +
  {
    spec+:
      {
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

local appHelm(name, repo, chart, revision='HEAD', namespace='default', values={}) =
  app(name) +
  {
    spec+: {
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

local serverSideApply = {
  spec+: {
    syncPolicy+: {
      syncOptions+: [
        'ServerSideApply=true',
      ],
    },
  },
};

{
  appFolder: appFolder,
  appHelm: appHelm,
  serverSideApply: serverSideApply,
}
