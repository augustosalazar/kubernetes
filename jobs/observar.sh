#!/usr/bin/env bash
# Atajo para ver de un vistazo el estado del ejercicio.
NS="${1:-ejercicio}"

echo; echo "=== Jobs ==="
kubectl get jobs -n "$NS"

echo; echo "=== Pods (con nodo y reinicios) ==="
kubectl get pods -n "$NS" -o wide

echo; echo "=== Pods por nodo ==="
kubectl get pods -n "$NS" -o wide --no-headers 2>/dev/null \
  | awk '{print $7}' | sort | uniq -c || echo "    (todavia no hay Pods)"

echo; echo "=== Ultimos eventos ==="
kubectl get events -n "$NS" --sort-by=.lastTimestamp 2>/dev/null | tail -12
