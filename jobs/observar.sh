#!/usr/bin/env bash
# Atajo para ver de un vistazo el estado del ejercicio.
#   bash observar.sh [namespace]
NS="${1:-ejercicio}"

echo; echo "=== Jobs ==="
kubectl get jobs -n "$NS"

echo; echo "=== Pods (con nodo y reinicios) ==="
kubectl get pods -n "$NS" -o wide

echo; echo "=== Pods por nodo ==="
# La columna 7 de `-o wide` es NODE.
# Se guarda en una variable en vez de encadenar `|| echo ...`: uniq devuelve 0
# aunque no reciba nada, asi que el mensaje de "no hay Pods" nunca se veia.
por_nodo=$(kubectl get pods -n "$NS" -o wide --no-headers 2>/dev/null \
  | awk '{print $7}' | sort | uniq -c)
if [ -n "$por_nodo" ]; then
  echo "$por_nodo"
else
  echo "    (todavia no hay Pods)"
fi

echo; echo "=== Ultimos eventos ==="
eventos=$(kubectl get events -n "$NS" --sort-by=.lastTimestamp 2>/dev/null)
if [ -n "$eventos" ]; then
  # Cabecera aparte + las 12 ultimas lineas, para no perder los titulos.
  echo "$eventos" | head -1
  echo "$eventos" | tail -n +2 | tail -12
else
  echo "    (todavia no hay eventos)"
fi
