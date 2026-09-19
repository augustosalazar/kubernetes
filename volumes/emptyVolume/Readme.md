# emptyDir — un volumen compartido entre contenedores

Este ejemplo muestra cómo **dos contenedores del mismo Pod** comparten datos a
través de un volumen `emptyDir`.

El Deployment ejecuta:

- un contenedor **writer**, que crea un archivo
- un contenedor **reader**, que lo lee

Los dos montan **el mismo volumen** en `/data`.

---

## Inicio desde cero

```powershell
kubectl delete -f emptydir-deployment.yaml --ignore-not-found
```

```bash
kubectl delete -f emptydir-deployment.yaml --ignore-not-found
```

## Desplegar

```powershell
kubectl apply -f emptydir-deployment.yaml
kubectl get pods
```

```bash
kubectl apply -f emptydir-deployment.yaml
kubectl get pods
```

Debería aparecer **un** Pod con `READY 2/2`: un Pod, dos contenedores.

## Ver lo que hizo el reader sin entrar a nada

```powershell
kubectl logs deploy/emptydir-demo -c reader
```

```bash
kubectl logs deploy/emptydir-demo -c reader
```

Ahí ya se ve el contenido del archivo que escribió *el otro* contenedor.

## Entrar al contenedor reader

```powershell
kubectl exec -it deploy/emptydir-demo -c reader -- sh
```

```bash
kubectl exec -it deploy/emptydir-demo -c reader -- sh
```

> `-c reader` no es opcional: el Pod tiene dos contenedores y sin esa opción
> `kubectl` no sabe a cuál conectarse.
>
> En Windows, este comando necesita una consola interactiva de verdad. Funciona
> en Windows Terminal, PowerShell y CMD; en **PowerShell ISE se queda colgado**.

Dentro del contenedor:

```sh
ls /data
cat /data/file.txt
exit
```

La salida confirma dos cosas:

- el archivo lo escribió un contenedor **distinto**
- los dos ven **el mismo sistema de archivos**

---

## Lo que demuestra

- `emptyDir` tiene alcance de **Pod**
- Todos los contenedores del Pod ven **los mismos datos**
- Pueden cooperar sin red y sin Services: se pasan cosas por el sistema de archivos

## Ciclo de vida — compruébenlo

Miren la fecha que guardó el writer, borren el Pod y vuelvan a mirar:

```powershell
kubectl exec deploy/emptydir-demo -c reader -- cat /data/file.txt
kubectl delete pod -l app=emptydir-demo
kubectl get pods -w        # esperen a que el nuevo esté 2/2
kubectl exec deploy/emptydir-demo -c reader -- cat /data/file.txt
```

```bash
kubectl exec deploy/emptydir-demo -c reader -- cat /data/file.txt
kubectl delete pod -l app=emptydir-demo
kubectl get pods -w
kubectl exec deploy/emptydir-demo -c reader -- cat /data/file.txt
```

La fecha **cambió**. No es que el archivo se conservara: el volumen se destruyó
con el Pod viejo y el writer del Pod nuevo lo creó otra vez desde cero. Por eso
`emptyDir` sirve solo para **datos temporales**.

Compárenlo con [`../persistentVolumeClaim/`](../persistentVolumeClaim/), donde
esa misma prueba da el resultado contrario.

## Idea principal

> **`emptyDir` permite compartir datos rápido y de forma temporal entre
> contenedores del mismo Pod.**

## Limpieza

```powershell
kubectl delete -f emptydir-deployment.yaml --ignore-not-found
```

```bash
kubectl delete -f emptydir-deployment.yaml --ignore-not-found
```
