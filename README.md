# Homelab / server

Everything should be declarative
Use CoreOS with custom image so add the functionally needed

Split into two types of server 

- ### Storage server
  NAS server with bcachefs
  
- ### Compute node
  Three nodes k3s servers with [OS Image from here](https://github.com/ksev/ostree-images/tree/main/images/k3s-node)

1. Install selected images on the appropriate machines
2. Stand up k3s cluster on one machine, 
3. Install Cilium in cluster
```shell
$: cilium install --set=ipam.operator.clusterPoolIPv4PodCIDRList=10.42.0.0/16 --set kubeProxyReplacement=true --set ingressController.enabled=true --set gatewayAPI.enabled=true  --set prometheus.enabled=true --set operator.prometheus.enabled=true --set hubble.enabled=true --set hubble.metrics.enableOpenMetrics=true --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}" --set hubble.relay.enabled=true --set hubble.ui.enabled=true --version=1.15.0 --set device=team0 --set bgpControlPlane.enabled=true --set egressGateway.enabled=true --set k8sServiceHost=192.168.1.62 --set k8sServicePort=6443
```

4. Apply cilium config from the cilium folder

5. Install 1Password connect and Operator 
This needs to be done outside of ArgoCD to preserve bootstrap secrets
```
https://developer.1password.com/docs/k8s/k8s-operator/
```
5. Install ArgoCD in cluster
```shell
$: kubectl create namespace argocd
$: kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
$: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

6. Kick off sync by applying the root ArgoCD app
```shell
$: jsonnet -J lib/ root.jsonnet | kubectl apply -f -
```