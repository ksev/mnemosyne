local argocd = import 'argocd.libsonnet';

argocd.appHelm(
  'pi-hole',
  'https://mojo2600.github.io/pihole-kubernetes/',
  'pihole',
  revision='2.21.0',
  values={
    serviceDns: {
      loadBalancerIP: '10.50.1.1',
      type: 'LoadBalancer',
    },
  }
)
