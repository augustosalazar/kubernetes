<#
.SYNOPSIS
    Borra todo lo que creo el ejercicio: un solo namespace.
#>
param([string]$Namespace = 'ejercicio')

# Se fija explicitamente: si el perfil de quien ejecuta tuviera
# ErrorActionPreference = 'Stop', PowerShell convertiria en error terminante
# cualquier cosa que kubectl escriba en su stream de error, y el script moriria
# sin mostrar nada.
$ErrorActionPreference = 'Continue'


Write-Host "Borrando el namespace '$Namespace' y todo lo que contiene..." -ForegroundColor Yellow
kubectl delete namespace $Namespace
Write-Host 'Listo.' -ForegroundColor Green
