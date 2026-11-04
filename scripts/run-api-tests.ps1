# Executa os testes BDD (Cucumber/Gherkin) e de contrato (JSON Schema) da API no Windows.
#
# Uso (PowerShell, com o Docker Desktop aberto):
#   .\scripts\run-api-tests.ps1           Sobe API + Oracle + executor de testes no Docker (so precisa do Docker)
#   .\scripts\run-api-tests.ps1 -Local    Usa a API ja em execucao e o Maven/Java 21 instalados na maquina
param(
    [switch]$Local,
    [string]$BaseUrl = 'http://localhost:8080',
    [string]$Tags = ''
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$report = Join-Path $projectRoot 'esg-api-tests\target\cucumber-reports\cucumber.html'

Push-Location $projectRoot
try {
    if (-not (Test-Path '.env')) { Copy-Item '.env.example' '.env' }

    if ($Local) {
        $mvnArgs = @('-B', '-f', 'esg-api-tests/pom.xml', 'test', "-Dapi.baseUrl=$BaseUrl")
        if ($Tags) { $mvnArgs += "-Dcucumber.filter.tags=$Tags" }
        & mvn @mvnArgs
        $status = $LASTEXITCODE
    }
    else {
        $compose = @('compose', '-f', 'docker-compose.yml', '-f', 'docker-compose.override.yml', '-f', 'docker-compose.tests.yml')
        Write-Host '>> Subindo Oracle + API + testes (a primeira execucao do Oracle leva de 1 a 3 minutos)'
        & docker @compose up --build --abort-on-container-exit --exit-code-from api-tests
        $status = $LASTEXITCODE
        # Remove os containers, mas preserva o volume do banco
        & docker @compose down
    }

    if ($status -eq 0) { Write-Host ">> Testes aprovados. Relatorio: $report" -ForegroundColor Green }
    else { Write-Host ">> Testes com falha (codigo $status). Relatorio: $report" -ForegroundColor Red }

    if (Test-Path $report) { Start-Process $report }
    exit $status
}
finally {
    Pop-Location
}
