# Aplicación web + base de datos

El escenario completo: una web con dos réplicas que se conecta a un PostgreSQL
con contraseña en un `Secret` y datos en un `PVC`.

## Modelo mental

```text
          ┌──────────────┐
          │   Usuario    │
          └──────┬───────┘
                 │
        ┌────────▼────────┐
        │  Service web    │  NodePort  (accesible desde fuera)
        └────────┬────────┘
                 │
         ┌───────▼────────┐
         │  Pods web (2)  │  imagen construida a mano
         └───────┬────────┘
                 │  DB_HOST=db  → DNS interno
        ┌────────▼────────┐
        │  Service db     │  ClusterIP (solo desde dentro)
        └────────┬────────┘
                 │
         ┌───────▼────────┐
         │  Pod db        │  PostgreSQL
         │   + PVC        │  + Secret con la contraseña
         └────────────────┘
```

---

## Inicio desde cero

Ejecuten esta limpieza antes de empezar. Borra únicamente los recursos de este
escenario, incluido el PVC, para que PostgreSQL se inicialice de nuevo.

```sh
kubectl delete -f web-service.yaml -f web-deployment.yaml -f db-service.yaml -f db-deployment.yaml --ignore-not-found
kubectl delete -f db-pvc.yaml --ignore-not-found
kubectl delete secret db-secret --ignore-not-found
```

## 1. Apuntar Docker al demonio de minikube

La imagen se construye **dentro** de minikube: así no hace falta ningún registro.

```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

```bash
eval $(minikube docker-env)
```

> **Esto solo afecta a la ventana actual.** Si abren otra, hay que repetirlo. Es
> la causa número uno de "construí la imagen y Kubernetes dice que no existe":
> se construyó en el Docker de Windows, no en el de minikube.
>
> Para comprobar que quedó apuntando bien:
>
> ```powershell
> docker images | Select-String kube-apiserver
> ```
>
> ```bash
> docker images | grep kube-apiserver
> ```
>
> Si aparecen imágenes de Kubernetes, están en el demonio correcto.

## 2. Construir la imagen

Desde esta carpeta:

```sh
docker build -t simple-web-db:1.0 .
docker images simple-web-db
```

> El tag `:1.0` no es decorativo. Antes el manifiesto pedía `simple-web-db` a
> secas, que Kubernetes interpreta como `:latest`; con imágenes construidas a
> mano eso lleva a estar corriendo una versión vieja sin darse cuenta. Si
> cambian `app.py`, suban el número y actualícenlo también en
> `web-deployment.yaml`.

## 3. Crear el Secret

```sh
kubectl create secret generic db-secret --from-literal=password=example
```

## 4. Desplegar

En este orden:

```sh
kubectl apply -f db-pvc.yaml
kubectl apply -f db-deployment.yaml
kubectl apply -f db-service.yaml
kubectl apply -f web-deployment.yaml
kubectl apply -f web-service.yaml
kubectl get pods -w
```

Esperen a que los tres Pods estén `Running` y `READY 1/1`. La primera vez, la
descarga de PostgreSQL tarda un par de minutos.

## 5. Abrir la aplicación

```sh
minikube service web --url
```

> En Windows con el driver de Docker, este comando **no devuelve el prompt**:
> mantiene el túnel abierto mientras la ventana siga viva. Déjenla y usen otra.

Alternativa, idéntica en todos los sistemas:

```sh
kubectl port-forward service/web 8080:80
```

Recarguen varias veces: el nombre del Pod que atiende va cambiando entre las dos
réplicas. Eso es el Service balanceando.

---

## Cosas que van a salir mal (y qué significan)

| Síntoma | Causa | Qué hacer |
|---|---|---|
| Pod web en `ErrImagePull` / `ImagePullBackOff` | La imagen se construyó en el Docker de Windows, no en el de minikube | Repetir el paso 1 **en la misma ventana** y reconstruir |
| Pod db en `CrashLoopBackOff` | Antes: `initdb: directory exists but is not empty` | Ya corregido con `PGDATA` en un subdirectorio del volumen — ver el comentario en `db-deployment.yaml` |
| La web dice `password authentication failed` | El Secret `db-secret` es de otro ejercicio | Borrarlo y volver a crearlo, y borrar el Pod de db para que relea |
| PVC en `Pending` | No hay StorageClass por defecto | `kubectl get storageclass` |
| La web responde 503 al principio | PostgreSQL todavía arranca | Esperar; `kubectl logs deploy/db` |

Comandos de diagnóstico, iguales en los dos shells:

```sh
kubectl get pods -o wide
kubectl describe pod -l app=web
kubectl logs deploy/web
kubectl logs deploy/db
```

Y para probar el DNS interno desde dentro de un Pod web:

```sh
kubectl exec deploy/web -- python -c "import socket; print(socket.gethostbyname('db'))"
```

## Probar la persistencia

```sh
kubectl delete pod -l app=db
kubectl get pods -w
```

El Pod nuevo monta el mismo PVC: no vuelve a inicializar la base, la encuentra
hecha. Se ve en `kubectl logs deploy/db` — aparece
`database system was shut down` en vez del `initdb` de la primera vez.

## Limpieza

```sh
kubectl delete -f web-service.yaml -f web-deployment.yaml -f db-service.yaml -f db-deployment.yaml --ignore-not-found
kubectl delete -f db-pvc.yaml --ignore-not-found
kubectl delete secret db-secret --ignore-not-found
```

El PVC hay que borrarlo aparte, a propósito: si no, los datos siguen ahí.
