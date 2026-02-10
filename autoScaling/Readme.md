# Scaling Scenario

Clean with 
```bash
kubectl delete deploy,svc,hpa,pod --all
```

Apply the deployment:
```bash
kubectl apply -f my-app-deployment.yaml
```

Start the service:
```bash
kubectl apply -f my-app-service.yaml
```


Enable metrics on Minikube
```bash
minikube addons enable metrics-server
```


Wait until the metrics server is running, then run the command below to check the CPU usage of the pods:
```bash
kubectl top pods
```

Create the Horizontal Pod Autoscaler

```bash
kubectl apply -f my-app-hpa.yaml
```

Check the HPA status:
```bash
kubectl get hpa
```


To get the URL of the service, run the command below:
```bash
minikube service my-app-nginx-service --url
```





Execute the measurement script to test the response time of the application:
```bash
./measure_response_time.sh <URL>
```

To scale the deployment, run the command below:
```bash
kubectl scale deployment my-app-nginx-deployment --replicas=3
```

Execute the measurement script again to test the response time of the application after scaling:
```bash
./measure_response_time.sh <URL>
```



