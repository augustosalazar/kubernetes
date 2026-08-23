# Volúmenes en Kubernetes — panorama conceptual

Esta carpeta contiene **ejemplos de los principales tipos de volumen**, cada uno
implementado con un **Deployment** y documentado en su propia subcarpeta.

Este README de arriba da solo la **introducción conceptual**. Los comandos, los
experimentos y las observaciones están dentro de cada carpeta.

---

## Cómo leer esta carpeta

| Carpeta | Tipo de volumen | Qué demuestra |
|---|---|---|
| [`emptyVolume/`](emptyVolume/) | `emptyDir` | Dos contenedores del mismo Pod compartiendo archivos |
| [`configMap/`](configMap/) | `ConfigMap` | Configuración inyectada como archivos |
| [`secret/`](secret/) | `Secret` | Datos sensibles fuera de la imagen |
| [`persistentVolumeClaim/`](persistentVolumeClaim/) | `PVC` | Datos que sobreviven al borrado del Pod |

> **Modelo mental**
>
> **Los Deployments gestionan Pods. Los Pods poseen los volúmenes.**
> El comportamiento de un volumen depende de su *tipo* y del *ciclo de vida del Pod*.

---

## emptyDir

Almacenamiento temporal que se crea cuando arranca el Pod.

- Vive dentro de **un solo Pod**
- Lo comparten todos los contenedores de ese Pod
- Se borra cuando el Pod se borra o se recrea

> "Un directorio temporal que existe solo mientras vive el Pod."

---

## ConfigMap (como volumen)

Guarda configuración **no sensible** fuera de la imagen del contenedor.

- Se monta como archivos dentro del contenedor
- Permite cambiar la configuración sin reconstruir la imagen

> "Configuración inyectada en el contenedor en tiempo de ejecución."

---

## Secret (como volumen)

Igual que un ConfigMap, pero pensado para datos sensibles.

- Se monta como archivos de solo lectura
- Para credenciales y claves

> "Configuración sensible que no vive ni en la imagen ni en el código fuente."

**Importante:** un Secret está codificado en base64, **no cifrado**. Cualquiera
con permiso de lectura sobre el Secret puede verlo en claro. Es una separación de
responsabilidades, no una medida criptográfica.

---

## PersistentVolumeClaim (PVC)

Almacenamiento duradero e independiente del Pod.

- Los datos sobreviven al borrado del Pod
- El almacenamiento tiene su propio ciclo de vida

> "Un disco que se le pide al clúster y se le conecta a los Pods."

---

## Por qué todo usa Deployments

Los Pods son **efímeros** y **reemplazables**; el Deployment gestiona ese
reemplazo. Los volúmenes tienen que comportarse correctamente cuando los Pods
desaparecen y vuelven a aparecer, y esa es justamente la diferencia que separa a
`emptyDir` de un PVC.

---

## Conclusión

> **El tipo de volumen define cuánto duran los datos.
> El ciclo de vida del Pod define cuándo existen.
> El Deployment define cómo se reemplazan los Pods.**

---

## Nota para Windows / PowerShell

Todos los comandos de estas carpetas son idénticos en PowerShell y en bash,
con dos excepciones que sí importan:

1. **`kubectl exec -it ... -- sh`** necesita una consola de verdad. Funciona en
   Windows Terminal, PowerShell y CMD; en PowerShell ISE se queda colgado.
2. **Las comillas.** Si escriben `kubectl get secret db-secret -o jsonpath="{.data.password}"`
   en PowerShell, la cadena entre comillas dobles se interpola antes de llegar a
   kubectl. Usen **comillas simples**:

   ```powershell
   kubectl get secret db-secret -o jsonpath='{.data.password}'
   ```

Cada README repite lo que le aplique en su sitio.
