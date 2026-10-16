param(
    [string]$JavaHome = 'D:\java\jdk21',
    [string]$GradleHome = 'D:\gradle\gradle-8.10.2',
    [switch]$Rebuild,
    [switch]$Stop
)

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$stateDir = Join-Path $projectRoot '.mewcode'
$pidFile = Join-Path $stateDir 'remote.pid'
$javaExe = Join-Path $JavaHome 'bin\java.exe'
$jarFile = Join-Path $projectRoot 'build\libs\mewcode.jar'

if (Test-Path -LiteralPath $pidFile) {
    $serverPid = [int](Get-Content -LiteralPath $pidFile)
    $server = Get-CimInstance Win32_Process -Filter "ProcessId=$serverPid"
    if ($server -and $server.ExecutablePath -eq $javaExe -and
        $server.CommandLine -like "*`"$jarFile`"*--remote*") {
        if ($Stop -or $Rebuild) {
            Stop-Process -Id $serverPid
            Wait-Process -Id $serverPid -Timeout 15 -ErrorAction SilentlyContinue
        } else {
            Write-Output "Already running: http://localhost:18888 (PID $serverPid)"
            return
        }
    }
}
if ($Stop) { return }
if (!(Test-Path -LiteralPath $javaExe)) { throw "JDK not found: $javaExe" }

if ($Rebuild) {
    $env:JAVA_HOME = $JavaHome
    Push-Location $projectRoot
    try {
        & (Join-Path $GradleHome 'bin\gradle.bat') test shadowJar --console=plain
        if ($LASTEXITCODE -ne 0) { throw 'Build failed; service was not started.' }
    } finally { Pop-Location }
}
if (!(Test-Path -LiteralPath $jarFile)) { throw 'JAR not found. Run with -Rebuild.' }

$server = Start-Process -FilePath $javaExe -ArgumentList @(
    '-jar', "`"$jarFile`"", '--remote'
) -WorkingDirectory $projectRoot -WindowStyle Hidden -PassThru `
    -RedirectStandardOutput (Join-Path $stateDir 'remote.stdout.log') `
    -RedirectStandardError (Join-Path $stateDir 'remote.stderr.log')
Set-Content -LiteralPath $pidFile -Value $server.Id
Write-Output "Started: http://localhost:18888 (PID $($server.Id))"
