local argocd = import 'argocd.libsonnet';

[
  argocd.appFolder('cloudflare-ddns', 'apps/ddns/')
]
