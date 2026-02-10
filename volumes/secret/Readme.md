
# Secret – Sensitive Data as Files

This example shows how to use a **Secret** to provide sensitive data to a container using a volume.


---

## Create the Secret

```bash
kubectl create secret generic db-secret --from-literal=password=supersecret
```

Verify

```bash
kubectl get secret db-secret
```

## Apply the deployment

```bash
kubectl apply -f secret-deployment.yaml
```

Confirm that the Pod is running

```bash
kubectl get pods
```

## Verify the Secret inside the container

```bash
kubectl exec -it deploy/secret-demo -- sh
```

Inside

```bash
cat /secrets/password
```

Expect

```bash
supersecret
```

it’s not plaintext in YAML

```bash
kubectl get secret db-secret -o yaml
```