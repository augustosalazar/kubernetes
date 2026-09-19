# ConfigMap — configuración como archivos

Cómo usar un **ConfigMap** para darle configuración a un contenedor a través de
un volumen.

---

## Inicio desde cero

```sh
kubectl delete -f configmap-deployment.yaml --ignore-not-found
kubectl delete configmap app-config --ignore-not-found
```

## Crear el ConfigMap

Un ConfigMap llamado `app-config` con una sola pareja clave–valor,
`APP_MODE=production`:

```sh
kubectl create configmap app-config --from-literal=APP_MODE=production
kubectl get configmaps
```

> **Háganlo antes del `apply`.** Si el ConfigMap no existe, el Pod se queda en
> `ContainerCreating` con el evento `configmap "app-config" not found`. Se
> comprueba con `kubectl describe pod -l app=configmap-demo`.

## Aplicar el Deployment

```sh
kubectl apply -f configmap-deployment.yaml
kubectl get pods
```

## Comprobar que llegó al contenedor

Lo más rápido, sin entrar a nada:

```sh
kubectl exec deploy/configmap-demo -- cat /config/APP_MODE
```

Salida esperada:

```text
production
```

O entrando al contenedor:

```sh
kubectl exec -it deploy/configmap-demo -- sh
```

> En Windows este comando necesita una consola interactiva de verdad: funciona en
> Windows Terminal, PowerShell y CMD, pero en **PowerShell ISE se queda colgado**.

Dentro:

```sh
ls /config
cat /config/APP_MODE
exit
```

Fíjense en que **cada clave del ConfigMap es un archivo** dentro de `/config`.

---

## Para observar

Cambien el valor y miren qué pasa:

```sh
kubectl create configmap app-config --from-literal=APP_MODE=debug --dry-run=client -o yaml | kubectl apply -f -
kubectl exec deploy/configmap-demo -- cat /config/APP_MODE
```

El archivo montado se actualiza solo, sin recrear el Pod, aunque puede tardar
hasta unos dos minutos según la configuración del kubelet. Lo que **no** cambia solo
es una variable de entorno cargada desde un ConfigMap: eso sí exige reiniciar el Pod.

## Limpieza

```sh
kubectl delete -f configmap-deployment.yaml --ignore-not-found
kubectl delete configmap app-config --ignore-not-found
```
