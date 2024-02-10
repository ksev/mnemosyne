local argocd = import 'argocd.libsonnet';

argocd.appFolder('root', path='apps/') 
