
# Secret - sensitive data as files

Create the secret

```bash
kubectl create secret generic db-secret --from-literal=password=supersecret
```

Verify

```bash
kubectl get secret db-secret
```

Apply deployment

```bash
kubectl apply -f secret-deployment.yaml
```

Test

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