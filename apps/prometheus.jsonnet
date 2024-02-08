local argocd = import 'argocd.libsonnet';

argocd.appHelm(
  'prometheus',
  'https://prometheus-community.github.io/helm-charts',
  'kube-prometheus-stack',
  revision='56.6.1',
  namespace='prometheus',
  syncPolicy=[
    'ServerSideApply=true',
  ],
  values={
    grafana: {
      ingress: {
        enabled: true,
        ingressClassName: 'cilium',
        annotations: {
          'cert-manager.io/cluster-issuer': 'letsencrypt-issuer',
        },
        hosts: ['grafana.kotee.co'],
        tls: [{
          hosts: ['grafana.kotee.co'],
          secretName: 'grafana-tls',
        }],
      },
    },
    prometheus: {
      prometheusSpec: {
        additionalScrapeConfigs: [{
          job_name: 'homey',
          static_configs: [
            { targets: ['192.168.2.121:9414'] },
          ],
        }],
      },
    },
  }
)
