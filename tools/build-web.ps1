# Gera a versao de navegador (HTML5) do Hardenia com o Igor, sem abrir a IDE.
#
# Uso, na pasta do repositorio:
#   powershell -ExecutionPolicy Bypass -File tools\build-web.ps1
#   powershell -ExecutionPolicy Bypass -File tools\build-web.ps1 -Saida C:\hardenia-web
#
# Precisa do GameMaker instalado, com login feito e o modulo HTML5 baixado
# (na IDE: Target Manager -> HTML5, uma vez). Sai com codigo 0 se gerou o
# index.html; a pasta resultante e estatica e vai inteira para o servidor.
param(
    [string]$Saida = (Join-Path $env:TEMP "hardenia-web\out")
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
if (-not (Test-Path (Join-Path $runtime "html5"))) {
    throw "modulo HTML5 ausente em $runtime : na IDE, Target Manager -> HTML5 para baixar."
}
Write-Host "runtime: $runtime"

$build = Join-Path $env:TEMP "hardenia-web"
Remove-Item $Saida -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$build\out" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $Saida, "$build\out" | Out-Null

Write-Host "== compilando HTML5"
$compileLog = Join-Path $build "compile.log"
# o ffmpeg do Igor escreve no stderr; no PowerShell 5 isso viraria erro fatal
$ErrorActionPreference = "Continue"
& "$runtime\bin\igor\windows\x64\Igor.exe" -j=8 "--project=$proj" "--user=$userDir" "--runtimePath=$runtime" `
    "--cache=$build\cache" "--temp=$build\temp" "--of=$build\out\index.html" "--tf=$Saida" -- html5 folder *> $compileLog
$ErrorActionPreference = "Stop"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path "$Saida\index.html")) {
    Select-String -Path $compileLog -Pattern "error" | Select-Object -First 20 | ForEach-Object { Write-Host $_.Line }
    throw "compilacao falhou (log completo: $compileLog)"
}

Write-Host "OK: $Saida"
exit 0
