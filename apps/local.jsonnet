local argocd = import 'argocd.libsonnet';

[
  argocd.appFolder(app),
  for app in ['cloudflare-ddns', 'mqtt']
]
