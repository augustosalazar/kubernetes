# PersistentVolumeClaim – Real Persistence

This example demonstrates how a **PersistentVolumeClaim (PVC)** provides storage that **survives Pod deletion**.

---

## Create the PersistentVolumeClaim

Create the PVC:


```bash
kubectl apply -f pvc.yaml
```

Verify binding (expect bond):

```bash
kubectl get pvc
```

## Deploy the application

```bash
kubectl apply -f pvc-deployment.yaml
```

Confirm that the Pod is running

```bash
kubectl get pods
```

## Write data to the volume

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

## Delete Pod and verify data persistence

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
