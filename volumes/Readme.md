# Kubernetes Volumes – Conceptual Overview

This repository contains **examples of the main Kubernetes volume types**, each implemented using a **Deployment** and documented in its own folder.

This top-level README provides **conceptual introductions only**.  
Detailed commands, experiments, and observations are documented inside each folder.

---

## How to read this repository

- Each folder represents **one volume type**
- Each volume is used **inside a Deployment**

> **Key mental model**
>
> **Deployments manage Pods. Pods own volumes.**  
> Volume behavior depends on the *volume type* and the *Pod lifecycle*.

---

## emptyDir

**`emptyDir`** is temporary storage created when a Pod starts.

- Scoped to a **single Pod**
- Shared by all containers in that Pod
- Deleted when the Pod is deleted or recreated

Think of it as:
> “A temporary directory that exists only for the life of the Pod.”

---

## ConfigMap (as a volume)

A **ConfigMap** stores non-sensitive configuration outside the container image.

- Mounted as files inside the container
- Allows changing configuration without rebuilding images

Think of it as:
> “Configuration injected into the container at runtime.”

---

## Secret (as a volume)

A **Secret** is similar to a ConfigMap but intended for sensitive data.

- Mounted as read-only files
- Intended for credentials and keys

Think of it as:
> “Sensitive configuration kept out of images and source code.”

---

## PersistentVolumeClaim (PVC)

A **PersistentVolumeClaim** provides durable, long-lived storage.

- Data survives Pod deletion
- Storage is independent from Pods

Think of it as:
> “A disk requested from the cluster and attached to Pods.”

---

## Why everything uses Deployments

Pods are **ephemeral** and **replaceable**.  
Deployments manage that replacement.

Volumes must work correctly even when Pods disappear and reappear.

---

## Final takeaway

> **Volume type defines data lifetime.  
> Pod lifecycle defines when data exists.  
> Deployments define how Pods are replaced.**

Refer to each folder’s README for hands-on steps.
