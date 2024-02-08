local argocd = import 'argocd.libsonnet';

argocd.appFolder('gateway-crd', 'apps/gateway/')
