
# ConfigMap – Simple Example

This example shows how to use a **ConfigMap** to provide configuration data to a container using a volume.

---

## Create the ConfigMap

Create a ConfigMap named app-config with one key–value pair APP_MODE=production.

```bash
kubectl create configmap app-config --from-literal=APP_MODE=production
```

Verify that the ConfigMap was created successfully

```bash
kubectl get configmaps
```

## Apply the deployment

```bash
kubectl apply -f configmap-deployment.yaml
```

## Verify that the ConfigMap was created successfully

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