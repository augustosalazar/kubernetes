
# Simple Nginx Deployment

Here’s a simple example of how to deploy an Nginx application on Kubernetes.

```bash
kubectl apply -f my-app-deployment.yaml    
```

To check the status of the deployment, run the command below:

```bash
kubectl get deployments
```

Start the service by running the command below:

```bash
kubectl apply -f my-app-service.yaml
```

To check the status of the service, run the command below:

```bash
kubectl get services
``` 

To access the application, run the command below to get the external IP address of the service:

```bash
minikube service my-app-nginx-service --url
```