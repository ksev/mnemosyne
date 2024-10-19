local argocd = import 'argocd.libsonnet';

[
  argocd.appHelm(
    'valheim-k8s',
    'https://addyvan.github.io/valheim-k8s/',
    revision='2.0.1',
    namespace='valheim',
    values={
      worldName: "zixxy",
      serverName: "zyx",
      password: "hello123456",
      extraEnvironmentVars: {
        "BEPINEX": true
      },
      storage: {
        kind: "hostvol",
        hostvol: {
          path: "/mnt/storage/Valheim"
        }
      },
      serverStorage: {
        kind: "hostvol",
        hostvol: {
          path: "/mnt/storage/ValheimServer"
        }
      }
    }
  ),
]
