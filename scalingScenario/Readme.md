# Escalado — qué gana la aplicación al añadir réplicas

El Deployment de esta carpeta ejecuta un servidor HTTP **deliberadamente lento**:
duerme 2 segundos antes de responder. Con una sola réplica, varias peticiones
simultáneas se ponen en cola. Al escalar, se reparten.

El objetivo es medirlo, no suponerlo.


## Desplegar

```powershell
kubectl apply -f my-app-deployment.yaml
kubectl apply -f my-app-service.yaml
kubectl get pods -o wide
```

```bash
kubectl apply -f my-app-deployment.yaml
kubectl apply -f my-app-service.yaml
kubectl get pods -o wide
```

La primera vez tarda un poco: hay que descargar la imagen de Python.

## Obtener la URL

```powershell
minikube service slow-app-service --url
```

```bash
minikube service slow-app-service --url
```

> En Windows con el driver de Docker, este comando **no devuelve el prompt**:
> mantiene abierto un túnel mientras la ventana siga viva. Déjenla corriendo y
> midan desde otra ventana.

Alternativa que se comporta igual en todos los sistemas:

```powershell
kubectl port-forward service/slow-app-service 8080:80
# la URL para medir es entonces http://127.0.0.1:8080
```

```bash
kubectl port-forward service/slow-app-service 8080:80
```

## Medir con una réplica

```powershell
.\measure_latency.ps1 -Url <URL> -Requests 12 -Parallelism 4
```

```bash
bash measure_latency.sh <URL> 12 4
```

Anoten el **tiempo total**. Con una réplica y 12 peticiones de 2 s cada una,
debería rondar los 24 s: el servidor las atiende de una en una.

## Escalar y volver a medir

```powershell
kubectl scale deployment slow-app-deployment --replicas=3
kubectl get pods -w      # esperen a que los 3 estén Ready
```

```bash
kubectl scale deployment slow-app-deployment --replicas=3
kubectl get pods -w
```

**Esperen a que la columna READY diga `1/1` en los tres.** El manifiesto tiene una
`readinessProbe`; hasta que no la pasan, el Service no les manda tráfico. Si miden
antes, los números salen mezclados.

```powershell
.\measure_latency.ps1 -Url <URL> -Requests 12 -Parallelism 4
```

```bash
bash measure_latency.sh <URL> 12 4
```

---

## Preguntas

1. ¿Bajó el tiempo total a un tercio, o menos de lo esperado? ¿Por qué?
2. El tiempo de **cada** petición, ¿cambió? ¿Debería?
3. Con `-Parallelism 1`, ¿nota alguna diferencia tener 3 réplicas? ¿Qué dice eso
   sobre qué problema resuelve escalar horizontalmente?
4. ¿Qué pasa si escalan a más réplicas que peticiones en paralelo?

## Notas de PowerShell

- **No usen `curl`.** En Windows PowerShell 5.1 es un alias de `Invoke-WebRequest`
  y no entiende `-w`, `-o` ni `-s`. Por eso `measure_latency.ps1` mide con
  `System.Net.WebRequest` en vez de llamar a curl. Si prefieren curl, escriban
  `curl.exe` con la extensión.
- Si PowerShell se niega a ejecutar el `.ps1`:

  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  ```

- `measure_latency.ps1` usa un *runspace pool*, no `ForEach-Object -Parallel`,
  para que funcione también en Windows PowerShell 5.1.
- El manifiesto lleva dentro un script de shell con un *heredoc* (`<< 'EOF'`).
  Eso **no** es un problema en Windows: ese fragmento no lo ejecuta PowerShell,
  lo ejecuta el contenedor, que es Linux.

## Limpieza

```powershell
kubectl delete -f my-app-service.yaml
kubectl delete -f my-app-deployment.yaml
```

```bash
kubectl delete -f my-app-service.yaml
kubectl delete -f my-app-deployment.yaml
```
