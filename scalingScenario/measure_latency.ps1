<#
.SYNOPSIS
    Mide cuanto tarda un lote de peticiones contra el Service.

.DESCRIPTION
    Equivalente en PowerShell de measure_latency.sh. Lanza N peticiones con
    un paralelismo dado y muestra, por peticion, cuando empezo y cuanto tardo.

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

# --------------------------------------------------------------------------
# Ajustes de red. Los tres importan en Windows PowerShell 5.1 (.NET Framework)
# y son inofensivos en PowerShell 7.
# --------------------------------------------------------------------------

# .NET Framework limita a DOS las conexiones simultaneas por host. Sin esto,
# pedir -Parallelism 8 no sirve de nada: seis peticiones se quedan esperando un
# hueco y el tiempo que se mide es el de la cola del cliente, no el del servidor.
[System.Net.ServicePointManager]::DefaultConnectionLimit = [Math]::Max($Parallelism, 2)

# Sin esto, .NET espera un "100 Continue" que este servidor no envia.
[System.Net.ServicePointManager]::Expect100Continue = $false

# El servidor del ejercicio habla HTTP/1.0 y cierra la conexion despues de cada
# respuesta. .NET, en cambio, guarda esa conexion en su pool para reutilizarla;
# cuando le toca el turno, el socket ya esta muerto y la peticion falla al
# instante con "Se ha terminado la conexion: error inesperado de recepcion".
# Ese es exactamente el fallo que aparece a partir de la septima peticion.
# Cerrar la conexion en cada peticion lo elimina de raiz.
$SinKeepAlive = $true

Write-Host "URL         : $Url"
Write-Host "Peticiones  : $Requests"
Write-Host "Paralelismo : $Parallelism"
Write-Host ''

# Un pool de runspaces da paralelismo real y funciona igual en PowerShell 5.1
# y en 7. (ForEach-Object -Parallel solo existe a partir de la 7.)
$pool = [runspacefactory]::CreateRunspacePool(1, $Parallelism)
$pool.Open()

$peticion = {
    param($url, $n, $t0, $sinKeepAlive)

    $inicio = [math]::Round(([datetime]::UtcNow - $t0).TotalSeconds, 2)
    $cron = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $req = [System.Net.WebRequest]::Create($url)
        $req.Method = 'GET'
        $req.Timeout = 60000
        $req.ReadWriteTimeout = 60000
        if ($sinKeepAlive) { $req.KeepAlive = $false }
        # Sin esto, .NET Framework consulta la configuracion de proxy del
        # sistema en cada peticion y anade cientos de milisegundos.
        $req.Proxy = $null

        $resp = $req.GetResponse()
        $estado = [int]$resp.StatusCode
        $resp.Close()
    }
    catch {
        # La excepcion real viene envuelta en una MethodInvocationException.
        # Se desenvuelve para poder mostrar el motivo en una palabra en vez de
        # un parrafo que descuadra la tabla.
        $err = $_.Exception
        if ($err.InnerException) { $err = $err.InnerException }

        $desconocido = [System.Net.WebExceptionStatus]::UnknownError
        if ($err -is [System.Net.WebException] -and $err.Status -ne $desconocido) {
            # Windows PowerShell 5.1 da un Status util: ConnectFailure,
            # ReceiveFailure, ConnectionClosed, Timeout...
            $motivo = [string]$err.Status
        } else {
            # PowerShell 7 devuelve UnknownError casi siempre; el motivo real
            # esta en la excepcion mas interna (normalmente una SocketException).
            $fondo = $err
            while ($fondo.InnerException) { $fondo = $fondo.InnerException }
            $motivo = $fondo.Message
            # Corto, para que quepa en la columna sin descuadrar la tabla.
            if ($motivo.Length -gt 24) { $motivo = $motivo.Substring(0, 21) + '...' }
        }
        $estado = "ERROR: $motivo"
    }
    $cron.Stop()

    [pscustomobject]@{
        Peticion = $n
        Inicio   = $inicio
        Segundos = [math]::Round($cron.Elapsed.TotalSeconds, 3)
        Estado   = $estado
    }
}

$t0 = [datetime]::UtcNow
$total = [System.Diagnostics.Stopwatch]::StartNew()

$trabajos = foreach ($i in 1..$Requests) {
    $ps = [powershell]::Create()
    $ps.RunspacePool = $pool
    [void]$ps.AddScript($peticion).AddArgument($Url).AddArgument($i).AddArgument($t0).AddArgument($SinKeepAlive)
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
# El ancho fijo tambien impide que un mensaje de error largo descuadre las
# columnas numericas.
$resultados |
    Sort-Object Peticion |
    Format-Table @{L = 'Peticion'; E = { $_.Peticion }; W = 9 },
                 @{L = 'Inicio s'; E = { '{0,8:N2}' -f $_.Inicio }; W = 9 },
                 @{L = 'Tardo s'; E = { '{0,8:N3}' -f $_.Segundos }; W = 9 },
                 @{L = 'Estado'; E = { $_.Estado }; W = 34 } |
    Out-String -Width 80 |
    Write-Host

$correctas = @($resultados | Where-Object { $_.Estado -is [int] })
$fallidas = @($resultados).Count - $correctas.Count

if ($correctas.Count -gt 0) {
    $media = ($correctas | Measure-Object Segundos -Average).Average
    Write-Host ("Media por peticion : {0:N3} s" -f $media)
}
Write-Host ("Tiempo total       : {0:N2} s para {1} peticiones con {2} en paralelo" -f `
    $total.Elapsed.TotalSeconds, $Requests, $Parallelism)

if ($fallidas -gt 0) {
    Write-Host ''
    Write-Host ("ATENCION: fallaron {0} de {1} peticiones. La medicion no es valida." -f `
        $fallidas, $Requests) -ForegroundColor Yellow
    Write-Host '  - ConnectionClosed / ReceiveFailure: el tunel de `minikube service`' -ForegroundColor Yellow
    Write-Host '    se cayo. Prueben con kubectl port-forward, que es mas estable:' -ForegroundColor Yellow
    Write-Host '        kubectl port-forward service/slow-app-service 8080:80' -ForegroundColor Yellow
    Write-Host '  - ConnectFailure: no hay nadie escuchando en esa URL.' -ForegroundColor Yellow
    Write-Host '  - Timeout: el servidor tardo mas de 60 s; bajen -Requests.' -ForegroundColor Yellow
}
