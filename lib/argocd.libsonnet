local app(name) = {
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: name,
    namespace: 'argocd',
  },
  spec: {},
};

local appRepo(name, url, path, namespace='default') = 
  app(name) +
  {
    spec+:
      {
        project: 'default',
        source: {
          repoURL: url,
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
          namespace: namespace,
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

local appFolder(name, path='apps/%s' % name, namespace='default') =
  appRepo(name, 'https://github.com/ksev/mnemosyne.git', path, namespace);

local appHelm(name, repo, chart=name, revision='HEAD', namespace='default', values={}) =
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

local syncWave(nr) = {
  metadata+: {
    annotations+: {
      'argocd.argoproj.io/sync-wave': '%d' % nr,
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
  appRepo: appRepo,
  serverSideApply: serverSideApply,
  syncWave: syncWave,
}
