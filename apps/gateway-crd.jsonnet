local argocd = import 'argocd.libsonnet';

argocd.appRepo(
	'gateway-api-crd', 
	'https://github.com/kubernetes-sigs/gateway-api.git',
	'config/crd/experimental'
) + argocd.syncWave(-1)
