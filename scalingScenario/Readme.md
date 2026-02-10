# Scaling Scenario


Run the command below to replace the deployment:
```bash
kubectl apply -f my-app-deployment.yaml
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



