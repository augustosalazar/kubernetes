# emptyDir – Shared Volume Between Containers

This example demonstrates how **two containers in the same Pod** can share data using an **`emptyDir` volume**.

The Deployment runs:
- a **writer** container that creates a file
- a **reader** container that reads that file

Both containers mount the **same volume** at `/data`.

---

## Starting the Deployment

Create the Deployment using the provided manifest:

```bash
kubectl apply -f emptydir-deployment.yaml
```

Verify that the Pod is running:

```bash
kubectl get pods
```

You should see one Pod created by the Deployment.

---

## Observing shared storage between containers

The `emptyDir` volume is created once when the Pod starts and is shared by all containers inside that Pod.

---

## Entering the reader container

To inspect what the writer container has produced, open a shell inside the **reader** container:

```bash
kubectl exec -it deploy/emptydir-demo -c reader -- sh
```

This connects you directly to the reader container.

---

## Inspecting the shared volume

Inside the container, list the contents of the mounted directory:

```sh
ls /data
```

You should see a file created by the writer container:

```text
file.txt
```

Display its contents:

```sh
cat /data/file.txt
```

The output confirms that:
- the file was written by a **different container**
- both containers are accessing the **same filesystem**

---

## What this demonstrates

- `emptyDir` is **Pod-scoped**
- All containers in the same Pod see the **same data**
- Containers can cooperate without networking or services
- Data sharing happens through the filesystem

---

## Lifecycle note

If the Pod is deleted or recreated:
- the `emptyDir` volume is destroyed
- all data inside it is lost

This makes `emptyDir` suitable for **temporary data only**.

---

## Key takeaway

> **`emptyDir` enables fast, temporary data sharing between containers in the same Pod.**
