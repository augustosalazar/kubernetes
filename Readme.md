
# Minikube Setup Guide
minikube start

# Minikube Commands
minikube status
minikube stop
minikube delete


# Kubernetes Commands
kubectl get nodes
kubectl get pods --all-namespaces
kubectl get services --all-namespaces
kubectl get deployments --all-namespaces
kubectl get namespaces
kubectl get configmaps --all-namespaces
kubectl get secrets --all-namespaces
kubectl get ingress --all-namespaces
kubectl get pv
kubectl get pvc --all-namespaces
kubectl get events --all-namespaces
kubectl get storageclass
kubectl get statefulsets --all-namespaces

# Create a sample deployment
this create deployment, which will create a pod running the specified image.
kubectl create deployment nginx-deployment --image=nginx:latest

# Check the status of the deployment
kubectl get deployments
# Check the status of the pods
kubectl get pods
    
# To get into the terminel of a specific pod
kubectl exec -it nginx-deployment-<pod-id> -- /bin/bash


# Kubernetes Dashboard Setup
# Install Helm
minikube addons enable dashboard
minikube addons enable metrics-server


