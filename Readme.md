# Ejemplos de Kubernetes

Colección de ejercicios para aprender Kubernetes con un clúster local. Cada
carpeta es un tema independiente, con sus manifiestos y su propio README con los
pasos.

Los comandos comunes se muestran una sola vez. Cuando PowerShell (Windows) y
bash (Linux/macOS) requieren sintaxis distinta, se muestran ambas versiones;
esas diferencias están listadas más abajo.

---

## Contenido

| Carpeta | Tema |
|---|---|
| [`simpleNginx/`](simpleNginx/) | Deployment y Service mínimos: el "hola mundo" |
| [`scalingScenario/`](scalingScenario/) | Escalar réplicas y medir el efecto en la latencia |
| [`volumes/`](volumes/) | Los cuatro tipos de volumen: emptyDir, ConfigMap, Secret y PVC |
| [`jobs/`](jobs/) | Por qué existe `Job` si ya existe `Deployment` |
| [`webDbScenario/`](webDbScenario/) | Aplicación web + PostgreSQL con Secret y PVC |

---

## Requisitos

- Un clúster de Kubernetes local. Los ejemplos están probados con **minikube**;
  `kind` o Docker Desktop sirven igual salvo donde se indique.
- `kubectl` en el PATH y apuntando a ese clúster.
- Docker, solo para `webDbScenario` (hay que construir una imagen).

Comprobación rápida, idéntica en ambos shells:

```sh
kubectl version --client
kubectl get nodes
```

---

## Notas para Windows y PowerShell

Todo esto está verificado; son las cosas que de verdad se rompen al pasar de
bash a PowerShell.

**1. Permitir la ejecución de scripts `.ps1`.**
Por defecto Windows bloquea los scripts. Esto lo habilita solo para la ventana
actual, sin cambiar nada del sistema:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

**2. `curl` no es `curl`.**
En Windows PowerShell 5.1, `curl` es un alias de `Invoke-WebRequest` y no
entiende las opciones de curl (`-w`, `-o`, `-s`). Hay que llamar al ejecutable
real:

```powershell
curl.exe -s http://127.0.0.1:30080
```

En PowerShell 7 el alias ya no existe, pero `curl.exe` funciona en las dos
versiones. Úsenlo siempre.

**3. No redirijan la salida de `kubectl` con `>`.**
En PowerShell 5.1, `>` escribe el archivo en UTF-16 y `kubectl apply -f` después
no lo puede leer. Usen `Out-File -Encoding utf8`:

```powershell
kubectl get deploy my-app-nginx-deployment -o yaml | Out-File -Encoding utf8 copia.yaml
```

**4. `eval $(minikube docker-env)` no existe en PowerShell.**
El equivalente es:

```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

Y hay que repetirlo **en cada ventana nueva**: solo afecta a la sesión actual.

**5. Cuidado con guardar los `.sh` desde un editor de Windows.**
Si un `.sh` queda con finales de línea CRLF, no se ejecuta en Linux ni dentro de
un contenedor: falla con `syntax error: unexpected end of file`. El archivo
`.gitattributes` de este repo fuerza LF para `.sh`, `.yaml`, `.py` y `Dockerfile`,
y CRLF solo para `.ps1`. Si `git status` marca decenas de archivos modificados
sin que hayan cambiado, es exactamente ese problema; se arregla con:

```powershell
git add --renormalize .
```

**6. `kubectl exec -it` necesita una consola de verdad.**
Funciona en Windows Terminal, PowerShell y CMD, pero **no** en PowerShell ISE ni
en la consola integrada de algunos editores: se queda colgado. Si pasa, abran
una ventana normal.

**7. `minikube service <nombre> --url` deja un túnel abierto.**
Con el driver de Docker en Windows, el comando no devuelve el prompt: mantiene el
túnel vivo mientras la ventana esté abierta. Déjenla corriendo y trabajen en otra
ventana. La alternativa, que se comporta igual en todos los sistemas:

```sh
kubectl port-forward service/my-app-nginx-service 8080:80
```

**8. Los `.sh` de este repo no tienen bit de ejecución.**
Git está configurado con `filemode = false`, así que `./script.sh` puede fallar
con "Permission denied". Invóquenlos con el intérprete delante:

```bash
bash jobs/observar.sh
```

---

## Limpieza general

Cada carpeta explica cómo borrar lo suyo. Para dejar el clúster como estaba:

```sh
minikube delete
```
