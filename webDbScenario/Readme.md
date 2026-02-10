
# Web Application with Database


## Visual mental model


          ┌──────────────┐
          │   User       │
          └──────┬───────┘
                 │
        ┌────────▼────────┐
        │  Web Service    │  (NodePort / Ingress)
        └────────┬────────┘
                 │
         ┌───────▼────────┐
         │  Web Pods      │
         └───────┬────────┘
                 │
        ┌────────▼────────┐
        │  DB Service     │  (ClusterIP)
        └────────┬────────┘
                 │
         ┌───────▼────────┐
         │  DB Pod        │
         │   + PVC        │
         └────────────────┘


## Build the web image

To setup minikube to use the local Docker daemon, run the command below:

on MacOS/Linux:
```bash
eval $(minikube docker-env)
```

On Windows (PowerShell):
```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

Then, build the web image:


```bash
docker build -t simple-web-db .
```

## Create the secret

```bash
kubectl create secret generic db-secret --from-literal=password=example
```

## Test the full flow

```bash
kubectl apply -f db-pvc.yaml
kubectl apply -f db-deployment.yaml
kubectl apply -f db-service.yaml
kubectl apply -f web-deployment.yaml
kubectl apply -f web-service.yaml
```

Get the web URL:

```bash
minikube service web --url
```