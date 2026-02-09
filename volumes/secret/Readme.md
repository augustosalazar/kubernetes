
# Secret - sensitive data as files

Create the secret

```bash
kubectl create secret generic db-secret --from-literal=password=supersecret
```