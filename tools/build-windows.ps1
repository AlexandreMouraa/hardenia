# Gera o zip de Windows do Hardenia com o Igor, sem abrir a IDE (o mesmo que
# Create Executable -> Package as Zip).
#
# Uso, na pasta do repositorio:
#   powershell -ExecutionPolicy Bypass -File tools\build-windows.ps1
#   powershell -ExecutionPolicy Bypass -File tools\build-windows.ps1 -Zip C:\hardenia-win\Hardenia-windows.zip
#
# Precisa do GameMaker instalado e com login feito. Sai com codigo 0 se gerou o zip.
param(
    [string]$Zip = (Join-Path $env:TEMP "hardenia-win\Hardenia-windows.zip")
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

$build = Join-Path $env:TEMP "hardenia-win-build"
Remove-Item "$build\out", $Zip -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path "$build\out", (Split-Path $Zip) | Out-Null

Write-Host "== compilando Windows (zip)"
$compileLog = Join-Path $build "compile.log"
# o ffmpeg do Igor escreve no stderr; no PowerShell 5 isso viraria erro fatal
$ErrorActionPreference = "Continue"
& "$runtime\bin\igor\windows\x64\Igor.exe" -j=8 "--project=$proj" "--user=$userDir" "--runtimePath=$runtime" `
    "--cache=$build\cache" "--temp=$build\temp" "--of=$build\out\Hardenia.win" "--tf=$Zip" -- windows PackageZip *> $compileLog
$ErrorActionPreference = "Stop"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $Zip)) {
    Select-String -Path $compileLog -Pattern "error" | Select-Object -First 20 | ForEach-Object { Write-Host $_.Line }
    throw "compilacao falhou (log completo: $compileLog)"
}

Write-Host "OK: $Zip"
exit 0
