
# Example of ConfigMap usage


Create a ConfigMap named app-config with one key–value pair APP_MODE=production.

```bash
kubectl create configmap app-config --from-literal=APP_MODE=production
```

Verify that the ConfigMap was created successfully by running the command below:

```bash
kubectl get configmaps
```

Apply the deployment

```bash
kubectl apply -f configmap-deployment.yaml
```

Test

```bash
kubectl exec -it deploy/configmap-demo -- sh
```

```bash
cat /config/APP_MODE
```

Expected output:

```bash
production
``` 