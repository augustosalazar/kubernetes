

Basic Test

1. Go to simpleNginx directory and run the command below to build the image:

```bash
kubectl apply -f my-app-deployment.yaml    
```

2. To check the status of the deployment, run the command below:

```bash
kubectl get deployments
```

3. Start the service by running the command below:

```bash
kubectl apply -f my-app-service.yaml
```

4. To check the status of the service, run the command below:

```bash
kubectl get services
``` 

5. To access the application, run the command below to get the external IP address of the service:

```bash
minikube service my-app-nginx-service --url
```

Scaling Scenario

With the deployment created in the previous section, we are going to replace the deployment to reach a scenario where scaling is needed. Go to slowContainer directory and :

1. Run the command below to replace the deployment:
```bash
kubectl apply -f my-app-deployment.yaml
```

2. To get the URL of the service, run the command below:
```bash
minikube service my-app-nginx-service --url
```

3. Execute the measurement script to test the response time of the application:
```bash
./measure_response_time.sh <URL>
```

4. To scale the deployment, run the command below:
```bash
kubectl scale deployment my-app-nginx-deployment --replicas=3
```

5. Execute the measurement script again to test the response time of the application after scaling:
```bash
./measure_response_time.sh <URL>
```



