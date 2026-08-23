# Nginx simple — Deployment y Service

El ejemplo más pequeño posible: un Deployment con dos réplicas de nginx y un
Service que las expone. Sirve para ver la relación entre las tres piezas —
Deployment, Pods, Service — antes de complicar nada.

---

## Desplegar

```powershell
kubectl apply -f my-app-deployment.yaml
```

Comprobar el estado del Deployment:

```powershell
kubectl get deployments
kubectl get pods -o wide
```

Deberían ver **dos** Pods. Ese número lo decide `replicas: 2` en el manifiesto,
no ustedes con un comando.

## Exponer el servicio

```powershell
kubectl apply -f my-app-service.yaml
kubectl get services
```

## Acceder a la aplicación

```powershell
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

```powershell
kubectl port-forward service/my-app-nginx-service 8080:80
# y en otra ventana:  curl.exe -s http://127.0.0.1:8080
```

```bash
kubectl port-forward service/my-app-nginx-service 8080:80
# y en otra terminal: curl -s http://127.0.0.1:8080
```

---

## Para observar

Borren un Pod y miren qué pasa:

Dejen `kubectl get pods -w` corriendo en una ventana y, en otra:

```powershell
kubectl delete pod -l app=my-app
```

El Deployment crea Pods nuevos enseguida: prometió mantener dos réplicas
corriendo. Comparen esto con lo que hace un `Job` en la carpeta [`jobs/`](../jobs/).

## Limpieza

```powershell
kubectl delete -f my-app-service.yaml
kubectl delete -f my-app-deployment.yaml
```


No es obligatorio borrarlo antes de pasar a `scalingScenario/` —aquel usa otros
nombres, otra etiqueta y otro NodePort—, pero deja el clúster más limpio.
