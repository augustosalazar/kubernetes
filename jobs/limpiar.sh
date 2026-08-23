#!/usr/bin/env bash
# Borra todo lo que creo el ejercicio: un solo namespace.
#   bash limpiar.sh [namespace]
NS="${1:-ejercicio}"
echo "Borrando el namespace '$NS' y todo lo que contiene..."
kubectl delete namespace "$NS"
echo "Listo."
