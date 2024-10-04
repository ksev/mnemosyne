local argocd = import 'argocd.libsonnet';

[
  argocd.appHelm(
    'valheim-k8s',
    'https://addyvan.github.io/valheim-k8s/',
    revision='2.0.1',
    namespace='valheim',
    values={
      worldName: "zixxy",
      serverName: "what",
      password: "hello123456"
    }
  ),
]
