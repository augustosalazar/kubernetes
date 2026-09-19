# Escalado — qué gana la aplicación al añadir réplicas

El Deployment de esta carpeta ejecuta un servidor HTTP **deliberadamente lento**:
duerme 2 segundos antes de responder. Con una sola réplica, varias peticiones
simultáneas se ponen en cola. Al escalar, se reparten.

El objetivo es medirlo, no suponerlo.

---

## Inicio desde cero

```sh
kubectl delete -f my-app-service.yaml --ignore-not-found
kubectl delete -f my-app-deployment.yaml --ignore-not-found
```

## Desplegar

```sh
kubectl apply -f my-app-deployment.yaml
kubectl apply -f my-app-service.yaml
kubectl rollout status deployment/slow-app-deployment
```

La primera vez tarda un poco: hay que descargar la imagen de Python.

## Obtener la URL

Ejecuten este comando en una terminal y déjenlo abierto; hagan las mediciones
desde otra terminal.

```sh
kubectl port-forward service/slow-app-service 8080:80
```

## Medir con una réplica

```powershell
.\measure_latency.ps1 -Url http://127.0.0.1:8080 -Requests 12 -Parallelism 2
```

```bash
bash measure_latency.sh http://127.0.0.1:8080 12 2
```
Anoten el **tiempo total**. Con una réplica y 12 peticiones de 2 s cada una,
debería rondar los 24 s: el servidor las atiende de una en una.

La columna **`Inicio s`** dice cuándo arrancó cada petición y **`Tardo s`** cuánto
esperó. Con `-Parallelism 2` verán algo así:

```text
 Peticion Inicio s  Tardo s    Estado
        1     0.03    2.067       200
        2     0.05    4.044       200
        3     2.12    3.978       200
        4     4.10    3.996       200
```

Dos peticiones entran a la vez, pero el servidor solo atiende una: la segunda de
cada pareja espera su turno y por eso tarda el doble. Ese "esperar turno" es lo
que desaparece al escalar.

## Escalar y volver a medir

```sh
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
- **Si ven `Se ha terminado la conexión: Error inesperado de recepción`** a
  partir de cierta petición —las primeras bien y el resto fallando al instante—
  es el pool de conexiones de .NET. El servidor habla HTTP/1.0 y cierra la
  conexión al terminar; .NET la guarda para reutilizarla y, cuando le toca el
  turno, el socket ya está muerto. El script lo evita con
  `$req.KeepAlive = $false`, y el servidor ahora envía `Content-Length` y
  `Connection: close` explícitos. **Si el error persiste, es el túnel de
  `minikube service`**: usen `kubectl port-forward`, que aguanta mucho mejor la
  concurrencia.
- Windows PowerShell 5.1 limita a **dos** las conexiones simultáneas por host.
  Sin tocarlo, pedir `-Parallelism 8` no sirve de nada: seis peticiones se
  quedan en la cola del cliente y lo que se mide es esa cola, no el servidor.
  El script sube el límite a `-Parallelism` al arrancar. En PowerShell 7 no
  existe ese tope, así que el mismo script daba resultados distintos según la
  versión.
- El manifiesto lleva dentro un script de shell con un *heredoc* (`<< 'EOF'`).
  Eso **no** es un problema en Windows: ese fragmento no lo ejecuta PowerShell,
  lo ejecuta el contenedor, que es Linux.

## Limpieza

```sh
kubectl delete -f my-app-service.yaml --ignore-not-found
kubectl delete -f my-app-deployment.yaml --ignore-not-found
```
