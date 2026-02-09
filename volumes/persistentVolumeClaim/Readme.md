# persistentVolumeClaim — real persistence

Create PVC

```bash
kubectl apply -f pvc.yaml
```

Verify binding (expect bond):

```bash
kubectl get pvc
```

Apply Deployment

```bash
kubectl apply -f pvc-deployment.yaml
```

Write data

```bash
kubectl exec -it deploy/pvc-demo -- sh
```

Inside (expect persistent):

```bash
cat /data/file.txt
```

```bash
exit
```

Delete Pod

```bash
kubectl delete pod -l app=pvc-demo
```

Wait for new Pod, then :

```bash
kubectl exec -it deploy/pvc-demo -- sh
```

Inside (Expect persistent)

```bash
cat /data/file.txt
```
