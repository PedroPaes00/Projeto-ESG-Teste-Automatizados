# esg-api-tests - Testes automatizados BDD da ESG Compliance API

Projeto de testes do **Desafio de Testes Automatizados** (Fase 6). Valida, de ponta a ponta, a ESG Compliance API
(governanca e compliance ambiental) rodando de verdade com o banco Oracle.

- **BDD com Gherkin** (em portugues) executado pelo **Cucumber 7** na JUnit Platform.
- **Testes de API** com **RestAssured**: status code, corpo da resposta (JSON) e **contrato com JSON Schema**.
- Execucao **local** (Docker ou Maven) e no **pipeline de CI** (GitHub Actions).

## Integrantes

- Paulo Ricardo - RM564600
- Pedro Joaquim Garceis Paes - RM565674

## Relacao com o ESG

O tema do projeto e **Governanca e compliance ambiental** (exemplo 4 do enunciado: testes que asseguram
integridade, rastreabilidade e conformidade regulatoria).

| Pilar | O que os testes garantem |
|---|---|
| Ambiental (E) | Licencas ambientais so sao aceitas com validade coerente; alertas de risco ambiental (ex.: efluentes acima do limite) sao registrados e tratados. |
| Social (S) | Perfis de acesso distintos (admin, auditor, analista) com respostas claras e padronizadas para cada situacao. |
| Governanca (G) | Codigo de licenca unico, auditorias apenas no presente/futuro, alertas nao podem ser "resolvidos" duas vezes, acesso negado sem credenciais, contratos de API estaveis. |

## Estrutura

```
esg-api-tests/
├── Dockerfile                          # Imagem do executor de testes (Maven + Java 21)
├── pom.xml                             # Cucumber, JUnit Platform, RestAssured, JSON Schema Validator
└── src/test/
    ├── java/br/com/projetof/esg/bdd/
    │   ├── RunCucumberTest.java        # Suite que executa as features e gera os relatorios
    │   ├── hooks/Hooks.java            # Aguarda a API ficar UP; registra o cenario para anexos
    │   ├── steps/ApiSteps.java         # Passos genericos: autenticacao, requisicoes, validacoes
    │   ├── steps/DadosEsgSteps.java    # Preparacao de dados (licenca e alerta via API)
    │   └── support/                    # Configuracao (URL/senhas) e contexto do cenario
    └── resources/
        ├── features/                   # Cenarios em Gherkin (5 funcionalidades, 39 cenarios)
        └── schemas/                    # Contratos JSON Schema (draft-04) das respostas
```

## Cenarios (resumo)

| Feature | Cenarios | Endpoints cobertos |
|---|:---:|---|
| `01_licencas_ambientais.feature` | 11 | `GET/POST /api/licenses`, `GET/PUT/DELETE /api/licenses/{id}` |
| `02_auditorias_internas.feature` | 6 | `GET/POST /api/audits` |
| `03_alertas_compliance.feature` | 8 | `GET/POST /api/alerts`, `GET /api/alerts/open`, `PATCH /api/alerts/{id}/resolve` |
| `04_dashboard_esg.feature` | 2 | `GET /api/dashboard/summary` |
| `05_seguranca_acesso.feature` | 12 | 401/403 em todos os modulos, `GET /actuator/health`, `GET /actuator/info` |
| **Total** | **39** | **12 endpoints da API + 2 do Actuator** |

Cada cenario tem tags para filtrar a execucao: `@positivo`, `@negativo`, `@contrato`, `@licencas`, `@auditorias`,
`@alertas`, `@dashboard`, `@seguranca`, `@governanca`, `@compliance`.

### Variaveis nos cenarios

Os passos aceitam variaveis entre chaves, resolvidas em tempo de execucao. Assim os testes podem rodar varias
vezes sobre o mesmo banco sem conflito de codigo de licenca.

| Variavel | Valor |
|---|---|
| `{codigoUnico}` | Codigo de licenca unico por cenario (ex.: `BDD-MH3K2L1A-7`) |
| `{hoje}` / `{daquiUmAno}` | Datas `yyyy-MM-dd` |
| `{dataHoraFutura}` / `{dataHoraPassada}` | Agora +30 dias / -30 dias (`yyyy-MM-ddTHH:mm:ss`) |
| `{licencaId}` / `{licencaCodigo}` | Licenca criada pelo passo "existe uma licenca ambiental cadastrada" |
| `{alertaId}` | Alerta criado pelo passo "existe um alerta de compliance em aberto" |

## Contratos (JSON Schema)

Ficam em `src/test/resources/schemas` e sao validados pelo passo
`o corpo da resposta deve respeitar o contrato "schemas/<arquivo>.json"`.

| Schema | Resposta validada |
|---|---|
| `license.json` / `license-list.json` | Licenca ambiental (campos obrigatorios, enum de status, datas, tamanhos) |
| `audit.json` / `audit-list.json` | Auditoria interna (enum de status, `findings` opcional) |
| `alert.json` / `alert-list.json` | Alerta de compliance (enum de severidade, `resolved` booleano) |
| `dashboard-summary.json` | Indicadores inteiros e nao negativos |
| `error.json` | Erro padronizado `ApiErrorResponse` (400, 401, 403, 404) |
| `health.json` / `info.json` | Endpoints publicos do Actuator |

Os schemas usam `additionalProperties: false` nos objetos da API: se um campo for removido, renomeado ou
adicionado sem atualizar o contrato, o teste falha.

## Como executar

### Opcao 1 - Tudo em Docker (recomendado, so precisa do Docker)

Na raiz do projeto:

```bash
./scripts/run-api-tests.sh
```

```powershell
# Windows (PowerShell, Docker Desktop aberto)
.\scripts\run-api-tests.ps1
```

O script sobe Oracle + API + executor de testes (`docker-compose.tests.yml`), espera a API ficar saudavel,
roda os 39 cenarios e derruba os containers ao final (o volume do banco e preservado).
Equivalente manual:

```bash
docker compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.tests.yml \
  up --build --abort-on-container-exit --exit-code-from api-tests
```

### Opcao 2 - Maven local contra uma API ja em execucao

Requer Java 21 e Maven.

```bash
docker compose up -d --build                     # sobe API + Oracle (se ainda nao estiver no ar)
mvn -f esg-api-tests/pom.xml test                # ou: ./scripts/run-api-tests.sh --local
```

Parametros opcionais (propriedade `-D` ou variavel de ambiente):

| Propriedade | Variavel | Padrao |
|---|---|---|
| `api.baseUrl` | `API_BASE_URL` | `http://localhost:8080` |
| `api.waitTimeout` | `API_WAIT_TIMEOUT` | `300` (segundos esperando o health ficar UP) |
| `api.adminPassword` / `api.auditorPassword` / `api.analystPassword` | `ADMIN_PASSWORD` / `AUDITOR_PASSWORD` / `ANALYST_PASSWORD` | senhas locais do `.env.example` |
| `cucumber.filter.tags` | - | todos os cenarios |

Exemplos:

```bash
mvn -f esg-api-tests/pom.xml test -Dcucumber.filter.tags="@negativo"
mvn -f esg-api-tests/pom.xml test -Dcucumber.filter.tags="@licencas and @contrato"
mvn -f esg-api-tests/pom.xml test -Dapi.baseUrl=http://<ip-do-servidor>:8081
```

### Opcao 3 - Pipeline de CI (GitHub Actions)

O job **2. Integracao e testes BDD de API** de `.github/workflows/ci-cd.yml` sobe a stack com Docker Compose,
roda o smoke test e em seguida `mvn -f esg-api-tests/pom.xml test`. O resultado aparece no resumo da execucao
e o relatorio completo e publicado como artefato `relatorio-bdd-cucumber`. Se algum cenario falhar, a imagem
nao e publicada e os deploys de staging/producao nao acontecem.

## Relatorios e evidencias

Apos a execucao, em `esg-api-tests/target/cucumber-reports/`:

| Arquivo | Uso |
|---|---|
| `cucumber.html` | Relatorio visual: cada cenario, cada passo e, anexados, a requisicao enviada e a resposta recebida |
| `cucumber.json` | Resultado estruturado (integracao com outras ferramentas) |
| `cucumber.xml` | JUnit XML (usado no resumo do GitHub Actions) |

O console tambem mostra cada passo (plugin `pretty`) e o resumo final com a quantidade de cenarios e passos aprovados.
