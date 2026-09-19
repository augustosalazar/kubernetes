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

```powershell
kubectl get nodes          # debe listar al menos un nodo en estado Ready
```

```bash
kubectl get nodes
```

Con varios nodos los experimentos se ven mejor, porque el reintento puede
cambiar de máquina. Con uno solo, todo lo demás funciona igual.

## Preparación

Para repetir el ejercicio desde cero, borren primero su namespace. `--wait=true`
espera a que desaparezca antes de crearlo otra vez.

```powershell
kubectl delete namespace ejercicio --ignore-not-found --wait=true
```

```bash
kubectl delete namespace ejercicio --ignore-not-found --wait=true
```

```powershell
cd jobs
kubectl apply -f 01-namespace.yaml
```

```bash
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

```powershell
kubectl apply -f 02-job-que-termina.yaml
kubectl get pods -n ejercicio -o wide -w
```

```bash
kubectl apply -f 02-job-que-termina.yaml
kubectl get pods -n ejercicio -o wide -w
```

En la otra ventana, mientras la cuenta avanza:

```powershell
kubectl logs -n ejercicio -l job-name=trabajo -f
```

```bash
kubectl logs -n ejercicio -l job-name=trabajo -f
```

Ahora, **sin esperar a que termine**, mátenle el Pod:

```powershell
kubectl delete pod -n ejercicio -l job-name=trabajo
```

```bash
kubectl delete pod -n ejercicio -l job-name=trabajo
```

**Preguntas:**

1. ¿Desapareció el trabajo, o apareció un Pod nuevo?
2. ¿El Pod nuevo tiene el mismo nombre que el anterior? ¿Y el mismo nodo?
3. La cuenta, ¿siguió donde iba o volvió a empezar en 1? ¿Por qué?
4. ¿Cuántos Pods ve `kubectl get pods` en total? ¿Qué representa ese número?

Cuando termine, fíjense en que el Job queda en `Completed` y deja de crear
Pods. Ese "dejar de crear" es la diferencia con todo lo que vieron antes.

## Experimento 2 — Reintentos hasta agotar el presupuesto

```powershell
kubectl apply -f 03-job-que-falla-never.yaml
kubectl get pods -n ejercicio -o wide -w
```

```bash
kubectl apply -f 03-job-que-falla-never.yaml
kubectl get pods -n ejercicio -o wide -w
```

Este Job falla siempre. Déjenlo correr un par de minutos.

**Preguntas:**

1. ¿Cuántos Pods aparecieron? ¿Cuadra con `backoffLimit: 2`?
2. ¿Cuánto tiempo pasó entre un intento y el siguiente? ¿Es constante?
3. ¿En qué estado quedó el Job al final?

```powershell
kubectl describe job trabajo-falla-never -n ejercicio
```

```bash
kubectl describe job trabajo-falla-never -n ejercicio
```

Busquen la sección `Conditions` y la razón `BackoffLimitExceeded`.

## Experimento 3 — La misma falla, cambiando una sola palabra

```powershell
kubectl apply -f 04-job-que-falla-onfailure.yaml
kubectl get pods -n ejercicio -o wide -w
```

```bash
kubectl apply -f 04-job-que-falla-onfailure.yaml
kubectl get pods -n ejercicio -o wide -w
```

Este manifiesto es idéntico al anterior salvo por `restartPolicy: OnFailure`.

**Preguntas:**

1. ¿Cuántos Pods aparecieron esta vez?
2. Miren la columna `RESTARTS`. ¿Qué está pasando que antes no pasaba?
3. Con `OnFailure`, ¿puede un reintento ejecutarse en **otro nodo**? ¿Por qué?
4. Si su objetivo fuera demostrar que el sistema se recupera repartiendo trabajo
   entre máquinas, ¿cuál de las dos políticas necesitan?

Comparen las dos de un vistazo:

```powershell
kubectl get pods -n ejercicio -o wide
```

```bash
kubectl get pods -n ejercicio -o wide
```

## Experimento 4 — El mismo contenedor como Deployment

Este es el importante.

```powershell
kubectl apply -f 05-deployment-mismo-trabajo.yaml
kubectl get pods -n ejercicio -w
```

```bash
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

```powershell
kubectl delete -f 05-deployment-mismo-trabajo.yaml
```

```bash
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

```powershell
kubectl delete -f 02-job-que-termina.yaml
kubectl apply  -f 02-job-que-termina.yaml
```

```bash
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

```powershell
kubectl delete namespace ejercicio --ignore-not-found --wait=true
```

```bash
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
| `02-job-que-termina.yaml` | Job que dura 60 s; para matarle el Pod a mitad |
| `03-job-que-falla-never.yaml` | Falla siempre, `restartPolicy: Never` |
| `04-job-que-falla-onfailure.yaml` | El mismo fallo, `restartPolicy: OnFailure` |
| `05-deployment-mismo-trabajo.yaml` | El mismo contenedor como Deployment |
| `observar.ps1` / `.sh` | Atajo: muestra Jobs, Pods y reparto por nodo |
| `limpiar.ps1` / `.sh` | Borra el namespace completo |
