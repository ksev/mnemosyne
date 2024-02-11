local argocd = import 'argocd.libsonnet';

[
  argocd.appHelm(
    'prowlarr',
    'https://github.com/pree/helm-charts.git',
    revision='1.30.0',
    values={
      metrics: {
        enabled: true,
      },
    },
    namespace=''
  ),
]
