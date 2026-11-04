# language: pt
@alertas @compliance
Funcionalidade: Alertas de conformidade ambiental
  Como auditor ESG
  Quero registrar, acompanhar e resolver alertas de conformidade
  Para tratar riscos ambientais antes que virem não conformidades

  @positivo @contrato
  Cenário: Listar todos os alertas de conformidade
    Dado que estou autenticado como "analyst"
    Quando envio uma requisição GET para "/api/alerts"
    Então o status da resposta deve ser 200
    E a resposta deve ser uma lista com ao menos 1 item
    E o corpo da resposta deve respeitar o contrato "schemas/alert-list.json"

  @positivo @contrato
  Cenário: Consultar somente os alertas em aberto
    Dado que existe uma licença ambiental cadastrada pelo administrador
    E que existe um alerta de compliance em aberto para essa licença
    E que estou autenticado como "analyst"
    Quando envio uma requisição GET para "/api/alerts/open"
    Então o status da resposta deve ser 200
    E a resposta deve ser uma lista com ao menos 1 item
    E o corpo da resposta deve respeitar o contrato "schemas/alert-list.json"
    E todos os itens da lista devem ter o campo "resolved" igual a "false"

  @positivo
  Cenário: Filtrar alertas não resolvidos por parâmetro
    Dado que estou autenticado como "auditor"
    Quando envio uma requisição GET para "/api/alerts?resolved=false"
    Então o status da resposta deve ser 200
    E o corpo da resposta deve respeitar o contrato "schemas/alert-list.json"
    E todos os itens da lista devem ter o campo "resolved" igual a "false"

  @positivo @contrato
  Cenário: Registrar um alerta crítico de conformidade
    Dado que existe uma licença ambiental cadastrada pelo administrador
    E que estou autenticado como "auditor"
    Quando envio uma requisição POST para "/api/alerts" com o corpo:
      """json
      {
        "licenseId": {licencaId},
        "severity": "CRITICAL",
        "message": "Emissao de efluentes acima do limite da licenca.",
        "resolved": false
      }
      """
    Então o status da resposta deve ser 201
    E o corpo da resposta deve respeitar o contrato "schemas/alert.json"
    E o campo "severity" da resposta deve ser "CRITICAL"
    E o campo "resolved" da resposta deve ser "false"
    E o campo "licenseCode" da resposta deve ser "{licencaCodigo}"

  @positivo @contrato
  Cenário: Resolver um alerta em aberto
    Dado que existe uma licença ambiental cadastrada pelo administrador
    E que existe um alerta de compliance em aberto para essa licença
    E que estou autenticado como "auditor"
    Quando envio uma requisição PATCH para "/api/alerts/{alertaId}/resolve"
    Então o status da resposta deve ser 200
    E o corpo da resposta deve respeitar o contrato "schemas/alert.json"
    E o campo "id" da resposta deve ser "{alertaId}"
    E o campo "resolved" da resposta deve ser "true"

  @negativo @contrato
  Cenário: Impedir que um alerta seja resolvido duas vezes
    Dado que existe uma licença ambiental cadastrada pelo administrador
    E que existe um alerta de compliance em aberto para essa licença
    E que estou autenticado como "auditor"
    Quando envio uma requisição PATCH para "/api/alerts/{alertaId}/resolve"
    E envio uma requisição PATCH para "/api/alerts/{alertaId}/resolve"
    Então o status da resposta deve ser 400
    E o corpo da resposta deve respeitar o contrato "schemas/error.json"
    E a mensagem de erro deve ser "O alerta informado ja esta resolvido."

  @negativo
  Cenário: Resolver um alerta inexistente
    Dado que estou autenticado como "admin"
    Quando envio uma requisição PATCH para "/api/alerts/999999/resolve"
    Então o status da resposta deve ser 404
    E a mensagem de erro deve ser "Alerta de compliance nao encontrado."

  @negativo
  Cenário: Rejeitar alerta sem mensagem
    Dado que estou autenticado como "auditor"
    Quando envio uma requisição POST para "/api/alerts" com o corpo:
      """json
      { "licenseId": 1, "severity": "LOW", "message": "", "resolved": false }
      """
    Então o status da resposta deve ser 400
    E a mensagem de erro deve ser "Payload invalido."
    E o campo "validations.message" da resposta deve existir
