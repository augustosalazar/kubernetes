# Secret — datos sensibles como archivos

Cómo usar un **Secret** para entregarle datos sensibles a un contenedor a través
de un volumen.

---

## Crear el Secret

```powershell
kubectl create secret generic db-secret --from-literal=password=supersecret
kubectl get secret db-secret
```

```bash
kubectl create secret generic db-secret --from-literal=password=supersecret
kubectl get secret db-secret
```

> **Háganlo antes del `apply`.** Sin el Secret, el Pod se queda en
> `ContainerCreating` con el evento `secret "db-secret" not found`.

## Aplicar el Deployment

```powershell
kubectl apply -f secret-deployment.yaml
kubectl get pods
```

```bash
kubectl apply -f secret-deployment.yaml
kubectl get pods
```

## Comprobar el Secret dentro del contenedor

```powershell
kubectl exec deploy/secret-demo -- cat /secrets/password
```

```bash
kubectl exec deploy/secret-demo -- cat /secrets/password
```

Esperado:

```text
supersecret
```

O entrando:

```powershell
kubectl exec -it deploy/secret-demo -- sh
```

```bash
kubectl exec -it deploy/secret-demo -- sh
```

> En Windows funciona en Windows Terminal, PowerShell y CMD; en **PowerShell ISE
> se queda colgado**.

---

## Lo importante: base64 no es cifrado

```powershell
kubectl get secret db-secret -o yaml
```

```bash
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

> **Usen comillas simples en el `jsonpath`.** Con comillas dobles, PowerShell
> interpola el contenido de las llaves antes de que kubectl lo vea y el comando
> devuelve algo distinto de lo que esperan.
>
> PowerShell no trae `base64`; por eso arriba se usa `[Convert]::FromBase64String`.

Un Secret **no es** una medida criptográfica: es una separación de
responsabilidades. Mantiene la credencial fuera de la imagen y fuera del código,
y permite darle permiso solo a quien lo necesite. Quien pueda leer el Secret, lo
lee en claro.

## Limpieza

```powershell
kubectl delete -f secret-deployment.yaml
kubectl delete secret db-secret
```

```bash
kubectl delete -f secret-deployment.yaml
kubectl delete secret db-secret
```

> Si van a seguir con [`../../webDbScenario/`](../../webDbScenario/), fíjense en
> que aquel también usa un Secret llamado `db-secret`, pero con **otra
> contraseña**. Borren este antes, o el PostgreSQL de allá arrancará con la
> contraseña equivocada.
