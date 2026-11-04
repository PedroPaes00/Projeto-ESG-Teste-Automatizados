#!/usr/bin/env bash
# Executa os testes BDD (Cucumber/Gherkin) e de contrato (JSON Schema) da API.
#
# Uso:
#   ./scripts/run-api-tests.sh           Sobe API + Oracle + executor de testes no Docker (so precisa do Docker)
#   ./scripts/run-api-tests.sh --local   Usa a API ja em execucao (API_BASE_URL, padrao http://localhost:8080)
#                                        e o Maven/Java 21 instalados na maquina
#
# Filtrar cenarios por tag (modo --local): CUCUMBER_TAGS="@licencas and @negativo" ./scripts/run-api-tests.sh --local
set -euo pipefail

cd "$(dirname "$0")/.."
[ -f .env ] || cp .env.example .env

REPORT="esg-api-tests/target/cucumber-reports/cucumber.html"

if [ "${1:-}" = "--local" ]; then
  args=(-B -f esg-api-tests/pom.xml test "-Dapi.baseUrl=${API_BASE_URL:-http://localhost:8080}")
  [ -n "${CUCUMBER_TAGS:-}" ] && args+=("-Dcucumber.filter.tags=${CUCUMBER_TAGS}")
  mvn "${args[@]}"
  echo ">> Relatorio: ${REPORT}"
  exit 0
fi

COMPOSE=(docker compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.tests.yml)

echo ">> Subindo Oracle + API + testes (a primeira execucao do Oracle leva de 1 a 3 minutos)"
set +e
"${COMPOSE[@]}" up --build --abort-on-container-exit --exit-code-from api-tests
status=$?
set -e

# Remove os containers, mas preserva o volume do banco (use "down -v" para zerar os dados)
"${COMPOSE[@]}" down

if [ "$status" -eq 0 ]; then
  echo ">> Testes aprovados. Relatorio: ${REPORT}"
else
  echo ">> Testes com falha (codigo ${status}). Relatorio: ${REPORT}"
fi
exit "$status"
