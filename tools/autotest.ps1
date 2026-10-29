# Robo de teste do Hardenia: compila o projeto com o Igor (o compilador do
# GameMaker) e deixa o jogo jogar sozinho, sem som e em janela.
#
# Uso, na pasta do repositorio:
#   powershell -ExecutionPolicy Bypass -File tools\autotest.ps1
#   powershell -ExecutionPolicy Bypass -File tools\autotest.ps1 -Runs 2 -Extra "-morrer"
#
# -Extra repassa opcoes ao robo: -morrer (morre uma vez por sala, testa a tela
# de morte), -desatento N (ignora N% dos avisos), -diag (log detalhado).
# Precisa do GameMaker instalado e com login feito pelo menos uma vez.
# Sai com codigo 0 se todas as runs terminaram em vitoria e sem erro.
param(
    [int]$Runs = 3,
    [int]$Speed = 240,
    [string]$Extra = "",
    [int]$TimeoutSec = 900
)
$ErrorActionPreference = "Stop"

$proj = (Resolve-Path (Join-Path $PSScriptRoot "..\Hardenia\Hardenia.yyp")).ProviderPath

# instalacao do GameMaker: runtime mais novo e pasta do usuario com licenca
$runtime = $null
$userDir = $null
foreach ($data in Get-ChildItem $env:ProgramData -Directory -Filter "GameMakerStudio2*") {
    $rt = Get-ChildItem (Join-Path $data.FullName "Cache\runtimes") -Directory -Filter "runtime-*" -ErrorAction SilentlyContinue |
        Sort-Object Name | Select-Object -Last 1
    $lic = Get-ChildItem (Join-Path $env:APPDATA $data.Name) -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName "licence.plist") } | Select-Object -First 1
    if ($rt -and $lic) {
        $runtime = $rt.FullName
        $userDir = $lic.FullName
    }
}
if (-not $runtime) { throw "GameMaker nao encontrado, ou sem login: abra a IDE e entre com a conta uma vez." }
Write-Host "runtime: $runtime"

$build = Join-Path $env:TEMP "hardenia-autotest"
New-Item -ItemType Directory -Force -Path "$build\out" | Out-Null

Write-Host "== compilando"
$compileLog = Join-Path $build "compile.log"
& "$runtime\bin\igor\windows\x64\Igor.exe" -j=8 "--project=$proj" "--user=$userDir" "--runtimePath=$runtime" `
    "--cache=$build\cache" "--temp=$build\temp" "--of=$build\out\Hardenia.win" -- windows Compile *> $compileLog
if ($LASTEXITCODE -ne 0) {
    Select-String -Path $compileLog -Pattern "error" | Select-Object -First 20 | ForEach-Object { Write-Host $_.Line }
    throw "compilacao falhou (log completo: $compileLog)"
}

$saida = Join-Path $env:LOCALAPPDATA "Hardenia\autotest"
Remove-Item $saida -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "== jogando: $Runs run(s) $Extra"
$argumentos = @("-game", "`"$build\out\Hardenia.win`"", "-autotest", "-runs", $Runs, "-speed", $Speed) +
    ($Extra -split " " | Where-Object { $_ })
$jogo = Start-Process "$runtime\windows\x64\Runner.exe" -ArgumentList $argumentos -WorkingDirectory "$build\out" -PassThru
if (-not $jogo.WaitForExit($TimeoutSec * 1000)) {
    $jogo.Kill()
    Write-Host "TEMPO ESGOTADO ($TimeoutSec s)"
}

$log = Join-Path $saida "log.txt"
if (-not (Test-Path $log)) { throw "o robo nao gerou log: $log" }
$linhas = Get-Content $log | Select-Object -Skip 1 | ForEach-Object { , ($_ -split "`t") }

Write-Host "== resultado (log e prints em $saida)"
$linhas | Where-Object { $_[3] -eq "sala_limpa" } | ForEach-Object { Write-Host ("  run {0} {1} {2}" -f $_[1], $_[2], $_[4]) }
$problemas = @($linhas | Where-Object { $_[3] -match "^(ALERTA|FALHA|ERRO)" })
$problemas | ForEach-Object { Write-Host ("  {0} {1}: {2}" -f $_[2], $_[3], $_[4]) }
$resumo = $linhas | Where-Object { $_[3] -eq "resumo" } | Select-Object -Last 1
if ($resumo) { Write-Host "  $($resumo[4])" }

if ($problemas.Count -eq 0 -and $resumo -and $resumo[4] -match "vitorias=$Runs ") {
    Write-Host "OK"
    exit 0
}
Write-Host "PROBLEMAS ENCONTRADOS"
exit 1
