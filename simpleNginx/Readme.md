# Nginx simple — Deployment y Service

El ejemplo más pequeño posible: un Deployment con dos réplicas de nginx y un
Service que las expone. Sirve para ver la relación entre las tres piezas —
Deployment, Pods, Service — antes de complicar nada.

---

## Inicio desde cero

Ejecuten este bloque antes de empezar, incluso si ya hicieron el ejercicio. Solo
elimina los recursos de **esta** carpeta y permite repetirlo sin depender del
estado anterior.

```sh
kubectl delete -f my-app-service.yaml --ignore-not-found
kubectl delete -f my-app-deployment.yaml --ignore-not-found
```

## Desplegar

```sh
kubectl apply -f my-app-deployment.yaml
kubectl apply -f my-app-service.yaml
```

Comprobar el estado del Deployment:

```sh
kubectl get deployments
kubectl get pods -o wide
```

Deberían ver **dos** Pods. Ese número lo decide `replicas: 2` en el manifiesto,
no ustedes con un comando.

## Comprobar el Service

```sh
kubectl get services
```

## Acceder a la aplicación

```sh
minikube service my-app-nginx-service --url
```

> **En Windows con el driver de Docker**, este comando no devuelve el prompt:
> mantiene un túnel abierto mientras la ventana siga viva. Déjenla corriendo y
> abran otra ventana para lo demás.

Con la URL que imprime:

```powershell
curl.exe -s <URL>
```

```bash
curl -s <URL>
```

> En PowerShell **hay que escribir `curl.exe`**, con la extensión. `curl` a secas
> es un alias de `Invoke-WebRequest` y no acepta las mismas opciones.

Alternativa que funciona igual en todos los sistemas y no depende de minikube:

```sh
kubectl port-forward service/my-app-nginx-service 8080:80
```

En otra terminal, prueben la URL con el comando correspondiente:

```powershell
curl.exe -s http://127.0.0.1:8080
```

```bash
curl -s http://127.0.0.1:8080
```

---

## Para observar

Borren un Pod y miren qué pasa:

Dejen `kubectl get pods -w` corriendo en una ventana y, en otra:

```sh
kubectl delete pod -l app=my-app
```

El Deployment crea Pods nuevos enseguida: prometió mantener dos réplicas
corriendo. Comparen esto con lo que hace un `Job` en la carpeta [`jobs/`](../jobs/).

## Limpieza

```sh
kubectl delete -f my-app-service.yaml --ignore-not-found
kubectl delete -f my-app-deployment.yaml --ignore-not-found
```
