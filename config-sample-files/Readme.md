# Sample Kubernetes Configuration Files

Each file defines a single kind of object in Kubernetes, and together they form a complete, working “echo” application:

- Namespace: isolation

- ConfigMap/Secret: configuration & credentials

- PV/PVC: durable storage

- Deployment: app definition & scale

- Service: internal networking

- Ingress: external traffic routing

## Usage
To deploy the echo application, apply the following files in order:
```bash
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```