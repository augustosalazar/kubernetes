<#
.SYNOPSIS
    Atajo para ver de un vistazo el estado del ejercicio.
.NOTES
    Deliberadamente simple: no depende de nada del proyecto del curso.
    Si PowerShell se niega a ejecutarlo:
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#>
param([string]$Namespace = 'ejercicio')

# Se fija explicitamente: si el perfil de quien ejecuta tuviera
# ErrorActionPreference = 'Stop', PowerShell convertiria en error terminante
# cualquier cosa que kubectl escriba en su stream de error, y el script moriria
# sin mostrar nada.
$ErrorActionPreference = 'Continue'


Write-Host "`n=== Jobs ===" -ForegroundColor Cyan
kubectl get jobs -n $Namespace

Write-Host "`n=== Pods (con nodo y reinicios) ===" -ForegroundColor Cyan
kubectl get pods -n $Namespace -o wide

Write-Host "`n=== Pods por nodo ===" -ForegroundColor Cyan
$salida = kubectl get pods -n $Namespace -o json 2>$null
if ($LASTEXITCODE -eq 0 -and $salida) {
    # -join: en Windows PowerShell 5.1 kubectl devuelve string[] y
    # ConvertFrom-Json falla si recibe las lineas sueltas.
    (($salida -join "`n") | ConvertFrom-Json).items |
        Group-Object { $_.spec.nodeName } |
        Format-Table @{L = 'Nodo'; E = { $_.Name } }, @{L = 'Pods'; E = { $_.Count } } -AutoSize
} else {
    Write-Host '    (todavia no hay Pods)'
}

Write-Host "=== Ultimos eventos ===" -ForegroundColor Cyan
kubectl get events -n $Namespace --sort-by=.lastTimestamp 2>$null | Select-Object -Last 12
