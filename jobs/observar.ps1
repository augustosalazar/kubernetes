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
    $items = (($salida -join "`n") | ConvertFrom-Json).items
    if ($items.Count -gt 0) {
        # Out-String -Width: sin esto la tabla sale VACIA si la salida del
        # script se redirige a un archivo o se canaliza, porque Format-Table
        # calcula el ancho a partir de la consola y ahi no hay consola.
        $items |
            Group-Object { $_.spec.nodeName } |
            Format-Table @{L = 'Nodo'; E = { $_.Name } }, @{L = 'Pods'; E = { $_.Count } } -AutoSize |
            Out-String -Width 120 |
            Write-Host
    } else {
        Write-Host '    (todavia no hay Pods)'
    }
} else {
    Write-Host "    (no se pudo consultar el namespace '$Namespace')"
}

Write-Host "=== Ultimos eventos ===" -ForegroundColor Cyan
$eventos = kubectl get events -n $Namespace --sort-by=.lastTimestamp 2>$null
if ($LASTEXITCODE -eq 0 -and $eventos) {
    # La primera linea es la cabecera: se conserva aparte, porque
    # `Select-Object -Last 12` a secas se la come cuando hay muchos eventos.
    $eventos = @($eventos)
    if ($eventos.Count -gt 1) {
        $eventos[0]
        $eventos[1..($eventos.Count - 1)] | Select-Object -Last 12
    } else {
        Write-Host '    (todavia no hay eventos)'
    }
} else {
    Write-Host '    (todavia no hay eventos)'
}
