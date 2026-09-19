# Secret — datos sensibles como archivos

Cómo usar un **Secret** para entregarle datos sensibles a un contenedor a través
de un volumen.

---

## Inicio desde cero

```sh
kubectl delete -f secret-deployment.yaml --ignore-not-found
kubectl delete secret db-secret --ignore-not-found
```

## Crear el Secret

```sh
kubectl create secret generic db-secret --from-literal=password=supersecret
kubectl get secret db-secret
```

> **Háganlo antes del `apply`.** Sin el Secret, el Pod se queda en
> `ContainerCreating` con el evento `secret "db-secret" not found`.

## Aplicar el Deployment

```sh
kubectl apply -f secret-deployment.yaml
kubectl get pods
```

## Comprobar el Secret dentro del contenedor

```sh
kubectl exec deploy/secret-demo -- cat /secrets/password
```

Esperado:

```text
supersecret
```

O entrando:

```sh
kubectl exec -it deploy/secret-demo -- sh
```

> En Windows funciona en Windows Terminal, PowerShell y CMD; en **PowerShell ISE
> se queda colgado**.

---

## Lo importante: base64 no es cifrado

```sh
kubectl get secret db-secret -o yaml
```

El valor no aparece en claro, pero está en **base64**, que se deshace en un
segundo:

```powershell
kubectl get secret db-secret -o jsonpath='{.data.password}' | ForEach-Object { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) }
```

```bash
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 -d
```

> **Usen comillas simples en el `jsonpath`** para que el comando sea idéntico en
> PowerShell y bash. En esta expresión concreta las comillas dobles también
> funcionan; las simples evitan problemas si más adelante se añade un `$`.
>
> PowerShell no trae `base64`; por eso arriba se usa `[Convert]::FromBase64String`.

Un Secret **no es** una medida criptográfica: es una separación de
responsabilidades. Mantiene la credencial fuera de la imagen y fuera del código,
y permite darle permiso solo a quien lo necesite. Quien pueda leer el Secret, lo
lee en claro.

## Limpieza

```sh
kubectl delete -f secret-deployment.yaml --ignore-not-found
kubectl delete secret db-secret --ignore-not-found
```
