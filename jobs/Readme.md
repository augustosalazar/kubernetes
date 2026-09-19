# Ejercicio: Jobs, o qué significa "trabajo que termina"

Cuatro experimentos de unos diez minutos en total. No dependen del proyecto del
curso ni de ninguna imagen propia: todo corre sobre `busybox`, que el clúster
descarga solo la primera vez.

**Objetivo:** entender, mirando el clúster y no una diapositiva, por qué existe
el objeto `Job` cuando ya existe `Deployment`.

---

## Requisitos

Un clúster de Kubernetes funcionando y `kubectl` apuntando a él. Sirve
cualquiera: minikube de uno o varios nodos, kind, o uno remoto.

```sh
kubectl get nodes
```

Con varios nodos los experimentos se ven mejor, porque el reintento puede
cambiar de máquina. Con uno solo, todo lo demás funciona igual.

## Preparación

Para repetir el ejercicio desde cero, borren primero su namespace. `--wait=true`
espera a que desaparezca antes de crearlo otra vez.

```sh
kubectl delete namespace ejercicio --ignore-not-found --wait=true
```

```sh
cd jobs
kubectl apply -f 01-namespace.yaml
```

Todo vive en el namespace `ejercicio` y se borra de una sola vez al final.

> Trabajen con **dos ventanas de terminal**: en una lanzan los comandos, en la
> otra dejan corriendo un `-w` para ver los Pods cambiar de estado en vivo.
> Casi todo lo interesante de este ejercicio ocurre mientras algo está pasando,
> no después.

---

## Experimento 1 — Un Job que termina, y qué pasa si le matan el Pod

```sh
kubectl apply -f 02-job-que-termina.yaml
kubectl get pods -n ejercicio -o wide -w
```

En la otra ventana, mientras la cuenta avanza:

```sh
kubectl logs -n ejercicio -l job-name=trabajo -f
```

Ahora, **sin esperar a que termine**, mátenle el Pod:

```sh
kubectl delete pod -n ejercicio -l job-name=trabajo
```

**Preguntas:**

1. ¿Desapareció el trabajo, o apareció un Pod nuevo?
2. ¿El Pod nuevo tiene el mismo nombre que el anterior? ¿Y el mismo nodo?
3. La cuenta, ¿siguió donde iba o volvió a empezar en 1? ¿Por qué?
4. ¿Cuántos Pods ve `kubectl get pods` en total? ¿Qué representa ese número?

Cuando termine, fíjense en que el Job queda en `Completed` y deja de crear
Pods. Ese "dejar de crear" es la diferencia con todo lo que vieron antes.

### Repetir el experimento

Un Job que terminó no vuelve a ejecutarse al aplicar el mismo manifiesto: su
trabajo ya está marcado como completado. Para iniciar una ejecución nueva,
borren el Job y créenlo de nuevo:

```sh
kubectl delete -f 02-job-que-termina.yaml
kubectl apply -f 02-job-que-termina.yaml
kubectl get pods -n ejercicio -o wide -w
```

## Experimento 2 — Reintentos hasta agotar el presupuesto

```sh
kubectl apply -f 03-job-que-falla-never.yaml
kubectl get pods -n ejercicio -o wide -w
```

Este Job falla siempre. Antes de observarlo, lean los tres límites que definen
su ciclo de vida:

```yaml
backoffLimit: 2
activeDeadlineSeconds: 600
ttlSecondsAfterFinished: 600
```

- `backoffLimit: 2` permite **dos reintentos** después del primer intento que
  falla. Con `restartPolicy: Never`, eso se ve normalmente como hasta **tres
  Pods** distintos: el inicial y dos reemplazos.
- `activeDeadlineSeconds: 600` pone un límite de **diez minutos para todo el
  Job**, incluidos los tiempos de espera progresivos entre reintentos. Si se
  alcanza antes de agotar `backoffLimit`, el Job termina por plazo vencido.
- `ttlSecondsAfterFinished: 600` no limita la ejecución: espera diez minutos
  **después** de que el Job termine como `Complete` o `Failed`, y entonces borra
  el Job y sus Pods.

En este ejercicio los fallos ocurren rápido, así que deberían agotarse primero
los dos reintentos y el Job debería terminar como `Failed`.

**Preguntas:**

1. ¿Cuántos Pods aparecieron? ¿Cuadra con `backoffLimit: 2`?
2. ¿Cuánto tiempo pasó entre un intento y el siguiente? ¿Es constante?
3. ¿En qué estado quedó el Job al final?

```sh
kubectl describe job trabajo-falla-never -n ejercicio
```

En la sección `Conditions`, confirmen la razón final: normalmente será
`BackoffLimitExceeded`. Si fuera `DeadlineExceeded`, el plazo total de diez
minutos se habría agotado antes de consumir los reintentos.

## Experimento 3 — La misma falla, cambiando una sola palabra

```sh
kubectl apply -f 04-job-que-falla-onfailure.yaml
kubectl get pods -n ejercicio -o wide -w
```

Este manifiesto es idéntico al anterior salvo por `restartPolicy: OnFailure`.

La diferencia está en **dónde se reintenta el trabajo**:

| Política | Después de `exit 1` | Qué deberían ver |
|---|---|---|
| `Never` | El Pod termina en `Error` y el Job crea otro Pod. | Varios Pods con nombres distintos; normalmente `RESTARTS` queda en 0. |
| `OnFailure` | El kubelet reinicia el contenedor dentro del mismo Pod. | Normalmente un solo Pod; la columna `RESTARTS` aumenta. |

Con `OnFailure`, los reintentos normales ocurren en el mismo Pod y, por tanto,
en el mismo nodo. Con `Never`, cada reintento usa un Pod nuevo y el scheduler
puede volver a decidir dónde ubicarlo; puede elegir otro nodo, aunque no está
garantizado. `backoffLimit`, `activeDeadlineSeconds` y
`ttlSecondsAfterFinished` conservan el mismo significado en ambas políticas.

**Preguntas:**

1. ¿Cuántos Pods aparecieron esta vez?
2. Miren la columna `RESTARTS`. ¿Qué está pasando que antes no pasaba?
3. Con `OnFailure`, ¿puede un reintento ejecutarse en **otro nodo**? ¿Por qué?
4. Si su objetivo fuera demostrar que el sistema se recupera repartiendo trabajo
   entre máquinas, ¿cuál de las dos políticas necesitan?

Comparen las dos de un vistazo:

```sh
kubectl get pods -n ejercicio -o wide
```

## Experimento 4 — El mismo contenedor como Deployment

Este es el importante.

```sh
kubectl apply -f 05-deployment-mismo-trabajo.yaml
kubectl get pods -n ejercicio -w
```

El trabajo es el mismo del experimento 1, solo que dura 20 segundos y va
envuelto en un `Deployment` en vez de un `Job`.

**Preguntas:**

1. El contenedor termina **bien**, con código de salida 0. ¿Qué hace el
   Deployment con él?
2. ¿Qué pasa con la columna `RESTARTS` a lo largo de un par de minutos?
3. Al rato el Pod entra en `CrashLoopBackOff`. ¿Es un error del contenedor?
4. Formulen en una frase la promesa que hace cada objeto. ¿En qué se
   contradicen cuando el trabajo termina?

Bórrenlo antes de seguir, o se quedará reiniciándose:

```sh
kubectl delete -f 05-deployment-mismo-trabajo.yaml
```

---

## Los atajos

Dos scripts para no repetir comandos. Hacen lo mismo; usen el de su sistema.

```powershell
.\observar.ps1        # Jobs, Pods, reparto por nodo y últimos eventos
.\limpiar.ps1         # borra el namespace completo
```

```bash
bash observar.sh      # Jobs, Pods, reparto por nodo y últimos eventos
bash limpiar.sh       # borra el namespace completo
```

Los dos aceptan otro namespace como argumento (`.\observar.ps1 -Namespace otro`,
`bash observar.sh otro`).

---

## Dos tropiezos que van a encontrar

**"field is immutable".** Si editan un Job ya creado —por ejemplo cambian
`SEGUNDOS`— y vuelven a hacer `apply`, la API lo rechaza. El `spec.template` de
un Job no se puede modificar: representa *una ejecución concreta*, no un estado
deseado que se ajusta. Hay que borrar y volver a crear:

```sh
kubectl delete -f 02-job-que-termina.yaml
kubectl apply  -f 02-job-que-termina.yaml
```

Un Deployment sí se deja editar en caliente. Esa asimetría no es un capricho:
es la misma diferencia de promesa que están investigando.

**El Job desapareció solo.** Los tres manifiestos de Job llevan
`ttlSecondsAfterFinished: 600`. Diez minutos después de terminar, el objeto y
sus Pods se borran automáticamente. Si vuelven al rato y no encuentran nada, no
se perdió: el TTL controller hizo su trabajo. El manifiesto de Deployment se
borra manualmente en el experimento 4.

## Notas para Windows y PowerShell

- **Para poder ejecutar los `.ps1`**, una sola vez por ventana:

  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  ```

- **El punto y la barra invertida son obligatorios**: `.\observar.ps1`.
  PowerShell no ejecuta scripts del directorio actual sin la ruta explícita.
- Los `.sh` de esta carpeta **no** tienen bit de ejecución (el repo está con
  `filemode = false`), así que en Linux/macOS conviene invocarlos como
  `bash observar.sh` en vez de `./observar.sh`.
- Los manifiestos llevan dentro scripts de shell. Eso no es problema en Windows:
  ese código no lo ejecuta PowerShell, lo ejecuta el contenedor, que es Linux.

## Limpieza

```sh
kubectl delete namespace ejercicio --ignore-not-found --wait=true
```

Un solo comando borra todo lo que crearon aquí. Puede tardar unos segundos.

---

## Lo que deberían poder responder al terminar

- Por qué `Deployment` no sirve para ejecutar una tarea, aunque técnicamente
  pueda lanzar el mismo contenedor.
- Qué garantiza `backoffLimit` y qué pasa cuando se agota.
- Por qué `restartPolicy: Never` y `OnFailure` producen evidencias distintas, y
  cuál necesitan si quieren demostrar recuperación entre nodos.
- Qué relación hay entre el número de Pods de un Job y su número de intentos.

Si las cuatro tienen respuesta, el paso siguiente —construir esos mismos objetos
desde código en vez de a mano— deja de ser un salto.

## Archivos

| Archivo | Para qué |
|---|---|
| `01-namespace.yaml` | Namespace `ejercicio`, aislado de todo lo demás |
| `02-job-que-termina.yaml` | Job que dura 120 s; para matarle el Pod a mitad |
| `03-job-que-falla-never.yaml` | Falla siempre, `restartPolicy: Never` |
| `04-job-que-falla-onfailure.yaml` | El mismo fallo, `restartPolicy: OnFailure` |
| `05-deployment-mismo-trabajo.yaml` | El mismo contenedor como Deployment |
| `observar.ps1` / `.sh` | Atajo: muestra Jobs, Pods y reparto por nodo |
| `limpiar.ps1` / `.sh` | Borra el namespace completo |
