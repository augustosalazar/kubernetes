#!/usr/bin/env bash
# Mide cuanto tarda un lote de peticiones contra el Service.
#
#   bash measure_latency.sh <URL> [PETICIONES] [PARALELISMO]
#
# Ejemplo:
#   bash measure_latency.sh http://127.0.0.1:30081 12 4
set -u

SERVICE_URL="${1:-}"
REQUESTS="${2:-12}"      # por defecto: 12 peticiones
PARALLELISM="${3:-4}"    # por defecto: 4 en paralelo  (antes estaba fijo en 4
                         # aunque el uso decia que se podia pasar por argumento)

if [ -z "$SERVICE_URL" ]; then
  echo "Uso: $0 <URL_DEL_SERVICIO> [PETICIONES] [PARALELISMO]" >&2
  exit 1
fi

echo "URL         : $SERVICE_URL"
echo "Peticiones  : $REQUESTS"
echo "Paralelismo : $PARALLELISM"
echo

inicio=$(date +%s)

# -I{} ya implica una linea por invocacion; anadir -n1 provoca un warning.
seq 1 "$REQUESTS" | xargs -P"$PARALLELISM" -I{} \
  curl -s -o /dev/null -w "  peticion {} tardo %{time_total}s\n" "$SERVICE_URL"

fin=$(date +%s)

echo
echo "Total: $((fin - inicio)) s para $REQUESTS peticiones con $PARALLELISM en paralelo"
