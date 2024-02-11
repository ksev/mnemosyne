local argocd = import 'argocd.libsonnet';

[
  argocd.appFolder('cloudflare-dns'),
  argocd.appFolder('mqtt'),
  argocd.appFolder('arr', namespace='arr'),
]
