# language: pt
@seguranca @governanca
Funcionalidade: Controle de acesso por perfil
  Como responsável pela governança de dados ESG
  Quero que cada perfil acesse apenas o que lhe é permitido
  Para garantir a integridade e a rastreabilidade das informações de compliance

  @negativo @contrato
  Esquema do Cenário: Bloquear acesso sem credenciais a "<endpoint>"
    Dado que não estou autenticado
    Quando envio uma requisição GET para "<endpoint>"
    Então o status da resposta deve ser 401
    E o corpo da resposta deve respeitar o contrato "schemas/error.json"
    E a mensagem de erro deve ser "Autenticacao obrigatoria para acessar este recurso."

    Exemplos:
      | endpoint               |
      | /api/licenses          |
      | /api/audits            |
      | /api/alerts            |
      | /api/alerts/open       |
      | /api/dashboard/summary |

  @negativo
  Cenário: Recusar credenciais com senha incorreta
    Dado que estou autenticado como "admin" com a senha "senha-errada"
    Quando envio uma requisição GET para "/api/licenses"
    Então o status da resposta deve ser 401
    E o corpo da resposta deve respeitar o contrato "schemas/error.json"

  @negativo @contrato
  Cenário: Analista não pode cadastrar licenças
    Dado que estou autenticado como "analyst"
    Quando envio uma requisição POST para "/api/licenses" com o corpo:
      """json
      {
        "code": "{codigoUnico}",
        "companyName": "Empresa Verde",
        "licenseType": "Licenca de Operacao",
        "status": "ACTIVE",
        "issuedAt": "{hoje}",
        "expiresAt": "{daquiUmAno}",
        "responsibleEmail": "esg@empresa.com.br"
      }
      """
    Então o status da resposta deve ser 403
    E o corpo da resposta deve respeitar o contrato "schemas/error.json"
    E o campo "status" da resposta deve ser "403"

  @negativo
  Cenário: Analista não pode agendar auditorias
    Dado que estou autenticado como "analyst"
    Quando envio uma requisição POST para "/api/audits" com o corpo:
      """json
      {
        "licenseId": 1,
        "auditorName": "Analista Sem Permissao",
        "scheduledAt": "{dataHoraFutura}",
        "status": "SCHEDULED"
      }
      """
    Então o status da resposta deve ser 403

  @negativo
  Cenário: Analista não pode resolver alertas
    Dado que estou autenticado como "analyst"
    Quando envio uma requisição PATCH para "/api/alerts/1/resolve"
    Então o status da resposta deve ser 403

  @negativo
  Cenário: Auditor não pode excluir licenças
    Dado que estou autenticado como "auditor"
    Quando envio uma requisição DELETE para "/api/licenses/1"
    Então o status da resposta deve ser 403

  @positivo @contrato
  Cenário: Health check público indica a aplicação disponível
    Dado que não estou autenticado
    Quando envio uma requisição GET para "/actuator/health"
    Então o status da resposta deve ser 200
    E o corpo da resposta deve respeitar o contrato "schemas/health.json"
    E o campo "status" da resposta deve ser "UP"

  @positivo @contrato
  Cenário: Informações públicas identificam a aplicação e o ambiente
    Dado que não estou autenticado
    Quando envio uma requisição GET para "/actuator/info"
    Então o status da resposta deve ser 200
    E o corpo da resposta deve respeitar o contrato "schemas/info.json"
    E o campo "app.name" da resposta deve ser "esg-compliance-api"
