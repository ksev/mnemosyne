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
cilium install --set=ipam.operator.clusterPoolIPv4PodCIDRList=10.42.0.0/16 --set bgpControlPlane.enabled=true --set kubeProxyReplacement=true --set ingressController.enabled=true --set k8sServiceHost=<change> --set k8sServicePort=6443 --set gatewayAPI.enabled=true
```
4. Install 1Password connect and Operator 
This needs to be done outside of ArgoCD to preserve bootstrap secrets
5. Install ArgoCD in cluster
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```