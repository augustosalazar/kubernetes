# Kubernetes Volumes – Hands‑on Examples (Deployments)

This repository contains **hands‑on Kubernetes volume examples**, each implemented using a **Deployment** (no standalone Pods), suitable for learning and teaching.

The goal is to understand:
- how volumes work in Kubernetes
- how they relate to Pods and Deployments
- how data behaves when Pods restart or are recreated

> **Important mental model**
>
> **Deployments create Pods. Pods own volumes.**  
> Each replica gets its *own* volume unless a shared persistent volume is used.

---

## Prerequisites


Verify cluster:

```bash
kubectl get nodes
```

---

## Repository Structure

```text
.
├── emptyDir/
│   ├── deployment.yaml
│   └── README.md
├── configMap/
│   ├── deployment.yaml
│   └── README.md
├── secret/
│   ├── deployment.yaml
│   └── README.md
├── pvc/
│   ├── pvc.yaml
│   ├── deployment.yaml
│   └── README.md
└── README.md   ← you are here
```

Each folder is **independent** and can be applied and tested on its own.

---

## 1️⃣ emptyDir

### What it is
`emptyDir` is **temporary storage** created when a Pod starts and deleted when the Pod stops.

- Scoped to a **single Pod**
- Shared by containers in the same Pod
- Deleted when the Pod is deleted

### Apply

```bash
kubectl apply -f emptyDir/deployment.yaml
```

### Test

```bash
kubectl exec -it deploy/emptydir-demo -- sh
cat /data/file.txt
```

### Restart the Pod

```bash
kubectl delete pod -l app=emptydir-demo
```

Run the test again — the file is recreated, not persisted.

### Key takeaway

> **`emptyDir` lives and dies with the Pod.**

---

## 2️⃣ ConfigMap (as a volume)

### What it is
A **ConfigMap** stores non‑secret configuration outside the container image.

- Managed by Kubernetes
- Mounted as files or injected as env vars
- Does not require rebuilding images

### Create ConfigMap

```bash
kubectl create configmap app-config --from-literal=APP_MODE=production
```

### Apply Deployment

```bash
kubectl apply -f configMap/deployment.yaml
```

### Test

```bash
kubectl exec -it deploy/configmap-demo -- sh
cat /config/APP_MODE
```

### Update configuration

```bash
kubectl create configmap app-config   --from-literal=APP_MODE=debug   -o yaml --dry-run=client | kubectl apply -f -
```

Restart Pods:

```bash
kubectl rollout restart deployment configmap-demo
```

### Key takeaway

> **Configuration is external to the image and environment‑specific.**

---

## 3️⃣ Secret (as a volume)

### What it is
A **Secret** stores sensitive data such as passwords or tokens.

- Similar to ConfigMaps
- Base64‑encoded (not encrypted by default)
- Mounted as read‑only files

### Create Secret

```bash
kubectl create secret generic db-secret   --from-literal=password=supersecret
```

### Apply Deployment

```bash
kubectl apply -f secret/deployment.yaml
```

### Test

```bash
kubectl exec -it deploy/secret-demo -- sh
cat /secrets/password
```

### Inspect the Secret

```bash
kubectl get secret db-secret -o yaml
```

### Key takeaway

> **Secrets should never be baked into images or committed to Git.**

---

## 4️⃣ PersistentVolumeClaim (PVC)

### What it is
A **PersistentVolumeClaim** provides **real, durable storage**.

- Data survives Pod deletion
- Backed by disks (cloud or local)
- Correct solution for databases and stateful apps

### Create PVC

```bash
kubectl apply -f pvc/pvc.yaml
kubectl get pvc
```

Ensure the PVC is **Bound**.

### Apply Deployment

```bash
kubectl apply -f pvc/deployment.yaml
```

### Test persistence

```bash
kubectl exec -it deploy/pvc-demo -- sh
cat /data/file.txt
```

Delete the Pod:

```bash
kubectl delete pod -l app=pvc-demo
```

Test again — data is still there.

### Key takeaway

> **PVCs decouple storage from Pods.**

---

## Comparison Summary

| Volume type | Survives Pod delete | Scope | Typical use |
|-----------|--------------------|------|-------------|
| emptyDir | ❌ No | Pod | Cache, temp files |
| ConfigMap | ✅ Yes | Cluster | App configuration |
| Secret | ✅ Yes | Cluster | Credentials |
| PVC | ✅ Yes | Cluster | Databases, state |

---

## Final takeaway

> **We don’t create Pods directly. We create Deployments.  
> Deployments create Pods. Pods own volumes.**

This separation is the foundation of Kubernetes storage.

---

## Cleanup (optional)

```bash
kubectl delete deployment --all
kubectl delete configmap app-config
kubectl delete secret db-secret
kubectl delete pvc pvc-demo
```

---

Happy experimenting 🚀
