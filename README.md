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
cilium install --set=ipam.operator.clusterPoolIPv4PodCIDRList=10.42.0.0/16 --set kubeProxyReplacement=true --set ingressController.enabled=true --set nodePort.enabled=true --set prometheus.enabled=true --set operator.prometheus.enabled=true --set hubble.enabled=true --set hubble.metrics.enableOpenMetrics=true --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}" --set l2announcements.enabled=true --set k8sClientRateLimit.qps=50 --set k8sClientRateLimit.burst=100 --set hostPort.enabled=true --set externalIPs.enabled=true --set hubble.relay.enabled=true  --set hubble.ui.enabled=true --version=1.15.0 --set device=team0 --set k8sServiceHost=192.168.4.62 --set k8sServicePort=6443
```
4. Install 1Password connect and Operator 
This needs to be done outside of ArgoCD to preserve bootstrap secrets
```
https://developer.1password.com/docs/k8s/k8s-operator/
```
5. Install ArgoCD in cluster
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```