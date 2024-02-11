local argocd = import 'argocd.libsonnet';

[
  argocd.appFolder('cloudflare-dns', namespace='pihole'),
  argocd.appFolder('mqtt', namespace='mqtt'),
  argocd.appFolder('arr', namespace='arr'),
]
