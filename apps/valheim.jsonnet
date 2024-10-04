local argocd = import 'argocd.libsonnet';

[
  argocd.appHelm(
    'valheim-k8s',
    'https://addyvan.github.io/valheim-k8s/',
    revision='2.22.0',
    namespace='valheim',
    values={
      worldName: "zixxy",
      serverName: "what",
      password: "hello123456"
    }
  ),
]
