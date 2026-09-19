# PersistentVolumeClaim — persistencia de verdad

Este ejemplo demuestra que un **PersistentVolumeClaim (PVC)** entrega
almacenamiento que **sobrevive al borrado del Pod**.

> **Qué cambió respecto a la versión anterior.** El contenedor hacía
> `echo persistent > /data/file.txt` en cada arranque, o sea que **reescribía el
> archivo cada vez**. Al borrar el Pod y volver a mirar, el archivo estaba ahí —
> pero habría estado ahí igual con un `emptyDir`, o sin volumen alguno. El
> experimento no probaba nada. Ahora el contenedor **añade** una línea con la
> fecha y el nombre del Pod en cada arranque, así que las líneas viejas son la
> prueba.

---

## Inicio desde cero

```powershell
kubectl delete -f pvc-deployment.yaml --ignore-not-found
kubectl delete -f pvc.yaml --ignore-not-found
```

```bash
kubectl delete -f pvc-deployment.yaml --ignore-not-found
kubectl delete -f pvc.yaml --ignore-not-found
```

## Crear el PVC

```powershell
kubectl apply -f pvc.yaml
kubectl get pvc
```

```bash
kubectl apply -f pvc.yaml
kubectl get pvc
```

Esperen a que el estado sea **`Bound`**. Si se queda en `Pending`, el clúster no
tiene una StorageClass por defecto que aprovisione sola:

```powershell
kubectl get storageclass
kubectl describe pvc pvc-demo
```

```bash
kubectl get storageclass
kubectl describe pvc pvc-demo
```

## Desplegar la aplicación

```powershell
kubectl apply -f pvc-deployment.yaml
kubectl get pods
```

```bash
kubectl apply -f pvc-deployment.yaml
kubectl get pods
```

## Mirar el estado inicial

```powershell
kubectl exec deploy/pvc-demo -- cat /data/arranques.txt
```

```bash
kubectl exec deploy/pvc-demo -- cat /data/arranques.txt
```

**Una** línea, con la hora y el nombre del Pod actual. Anótenlo.

## La prueba: borrar el Pod

```powershell
kubectl delete pod -l app=pvc-demo
kubectl get pods -w        # esperen a que el nuevo esté Running
```

```bash
kubectl delete pod -l app=pvc-demo
kubectl get pods -w
```

Y ahora:

```powershell
kubectl exec deploy/pvc-demo -- cat /data/arranques.txt
```

```bash
kubectl exec deploy/pvc-demo -- cat /data/arranques.txt
```

Ahora hay **dos** líneas, con **nombres de Pod distintos**. El Pod que escribió la
primera ya no existe. Eso es lo que demuestra el ejercicio: el archivo no lo
conservó el Pod, lo conservó el volumen.

Repítanlo un par de veces y verán la lista crecer.

---

## Preguntas

1. ¿Qué pasa con el archivo si borran el **Deployment** pero no el PVC?
2. ¿Y si borran el PVC?
3. Vayan a [`../emptyVolume/`](../emptyVolume/) y hagan la misma prueba. ¿Por qué
   allí el resultado es el contrario?
4. `accessModes: ReadWriteOnce` — ¿qué pasaría al escalar a `replicas: 3` en un
   clúster de varios nodos?

Comprueben el punto 1 antes de responder: es la parte contraintuitiva.

```powershell
kubectl delete -f pvc-deployment.yaml
kubectl get pvc                       # sigue ahí, Bound
kubectl apply -f pvc-deployment.yaml
kubectl exec deploy/pvc-demo -- cat /data/arranques.txt
```

```bash
kubectl delete -f pvc-deployment.yaml
kubectl get pvc
kubectl apply -f pvc-deployment.yaml
kubectl exec deploy/pvc-demo -- cat /data/arranques.txt
```

## Limpieza

```powershell
kubectl delete -f pvc-deployment.yaml --ignore-not-found
kubectl delete -f pvc.yaml --ignore-not-found
```

```bash
kubectl delete -f pvc-deployment.yaml --ignore-not-found
kubectl delete -f pvc.yaml --ignore-not-found
```

El PVC hay que borrarlo aparte: **no** desaparece con el Deployment. Esa es
justamente la diferencia.
