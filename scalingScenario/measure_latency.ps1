<#
.SYNOPSIS
    Mide cuanto tarda un lote de peticiones contra el Service.

.DESCRIPTION
    Equivalente en PowerShell de measure_latency.sh. Lanza N peticiones con
    un paralelismo dado y muestra el tiempo de cada una y el total.

    No usa curl a proposito: en Windows PowerShell 5.1 `curl` es un alias de
    Invoke-WebRequest y no acepta las opciones de curl. Aqui se usa
    System.Net.WebRequest, que existe en 5.1 y en 7.

.EXAMPLE
    .\measure_latency.ps1 -Url http://127.0.0.1:30081 -Requests 12 -Parallelism 4

.NOTES
    Si PowerShell se niega a ejecutarlo:
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#>
param(
    [Parameter(Mandatory = $true)][string]$Url,
    [int]$Requests = 12,
    [int]$Parallelism = 4
)

$ErrorActionPreference = 'Continue'

Write-Host "URL         : $Url"
Write-Host "Peticiones  : $Requests"
Write-Host "Paralelismo : $Parallelism"
Write-Host ''

# Un pool de runspaces da paralelismo real y funciona igual en PowerShell 5.1
# y en 7. (ForEach-Object -Parallel solo existe a partir de la 7.)
$pool = [runspacefactory]::CreateRunspacePool(1, $Parallelism)
$pool.Open()

$peticion = {
    param($url, $n)
    $cron = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $req = [System.Net.WebRequest]::Create($url)
        $req.Method = 'GET'
        $req.Timeout = 30000
        $resp = $req.GetResponse()
        $estado = [int]$resp.StatusCode
        $resp.Close()
    }
    catch {
        $estado = "ERROR: $($_.Exception.Message)"
    }
    $cron.Stop()
    [pscustomobject]@{
        Peticion = $n
        Segundos = [math]::Round($cron.Elapsed.TotalSeconds, 3)
        Estado   = $estado
    }
}

$total = [System.Diagnostics.Stopwatch]::StartNew()

$trabajos = foreach ($i in 1..$Requests) {
    $ps = [powershell]::Create()
    $ps.RunspacePool = $pool
    [void]$ps.AddScript($peticion).AddArgument($Url).AddArgument($i)
    [pscustomobject]@{ Shell = $ps; Handle = $ps.BeginInvoke() }
}

$resultados = foreach ($t in $trabajos) {
    $t.Shell.EndInvoke($t.Handle)
    $t.Shell.Dispose()
}

$total.Stop()
$pool.Close()
$pool.Dispose()

# Out-String -Width evita que la tabla salga vacia cuando la salida se redirige
# a un archivo o se canaliza: sin consola, Format-Table calcula ancho cero.
$resultados |
    Sort-Object Peticion |
    Format-Table Peticion, Segundos, Estado -AutoSize |
    Out-String -Width 120 |
    Write-Host

$correctas = @($resultados | Where-Object { $_.Estado -is [int] })
if ($correctas.Count -gt 0) {
    $media = ($correctas | Measure-Object Segundos -Average).Average
    Write-Host ("Media por peticion : {0:N3} s" -f $media)
}
Write-Host ("Tiempo total       : {0:N2} s para {1} peticiones con {2} en paralelo" -f `
    $total.Elapsed.TotalSeconds, $Requests, $Parallelism)
