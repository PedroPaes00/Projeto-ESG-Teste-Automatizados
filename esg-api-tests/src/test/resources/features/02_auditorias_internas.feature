# language: pt
@auditorias @compliance
Funcionalidade: Auditorias internas de compliance ambiental
  Como auditor ESG
  Quero agendar e consultar auditorias vinculadas às licenças ambientais
  Para comprovar o acompanhamento contínuo das obrigações regulatórias

  @positivo @contrato
  Cenário: Listar as auditorias internas
    Dado que estou autenticado como "analyst"
    Quando envio uma requisição GET para "/api/audits"
    Então o status da resposta deve ser 200
    E a resposta deve ser uma lista com ao menos 1 item
    E o corpo da resposta deve respeitar o contrato "schemas/audit-list.json"

  @positivo
  Cenário: Filtrar auditorias agendadas
    Dado que estou autenticado como "auditor"
    Quando envio uma requisição GET para "/api/audits?status=SCHEDULED"
    Então o status da resposta deve ser 200
    E o corpo da resposta deve respeitar o contrato "schemas/audit-list.json"
    E todos os itens da lista devem ter o campo "status" igual a "SCHEDULED"

  @positivo @contrato
  Cenário: Agendar uma auditoria futura para uma licença
    Dado que existe uma licença ambiental cadastrada pelo administrador
    E que estou autenticado como "auditor"
    Quando envio uma requisição POST para "/api/audits" com o corpo:
      """json
      {
        "licenseId": {licencaId},
        "auditorName": "Marina Duarte",
        "scheduledAt": "{dataHoraFutura}",
        "status": "SCHEDULED",
        "findings": "Verificar destinacao de residuos e consumo de agua."
      }
      """
    Então o status da resposta deve ser 201
    E o corpo da resposta deve respeitar o contrato "schemas/audit.json"
    E o campo "licenseId" da resposta deve ser "{licencaId}"
    E o campo "licenseCode" da resposta deve ser "{licencaCodigo}"
    E o campo "status" da resposta deve ser "SCHEDULED"

  @negativo @contrato
  Cenário: Rejeitar auditoria agendada para uma data passada
    Dado que existe uma licença ambiental cadastrada pelo administrador
    E que estou autenticado como "auditor"
    Quando envio uma requisição POST para "/api/audits" com o corpo:
      """json
      {
        "licenseId": {licencaId},
        "auditorName": "Marina Duarte",
        "scheduledAt": "{dataHoraPassada}",
        "status": "SCHEDULED"
      }
      """
    Então o status da resposta deve ser 400
    E o corpo da resposta deve respeitar o contrato "schemas/error.json"
    E a mensagem de erro deve ser "A auditoria deve ser agendada para o presente ou futuro."

  @negativo
  Cenário: Rejeitar auditoria para licença inexistente
    Dado que estou autenticado como "auditor"
    Quando envio uma requisição POST para "/api/audits" com o corpo:
      """json
      {
        "licenseId": 999999,
        "auditorName": "Marina Duarte",
        "scheduledAt": "{dataHoraFutura}",
        "status": "SCHEDULED"
      }
      """
    Então o status da resposta deve ser 404
    E a mensagem de erro deve ser "Licenca ambiental nao encontrada."

  @negativo
  Cenário: Rejeitar auditoria sem o nome do auditor
    Dado que estou autenticado como "auditor"
    Quando envio uma requisição POST para "/api/audits" com o corpo:
      """json
      {
        "licenseId": 1,
        "auditorName": "",
        "scheduledAt": "{dataHoraFutura}",
        "status": "SCHEDULED"
      }
      """
    Então o status da resposta deve ser 400
    E a mensagem de erro deve ser "Payload invalido."
    E o campo "validations.auditorName" da resposta deve existir
