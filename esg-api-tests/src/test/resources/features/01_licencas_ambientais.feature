# language: pt
@licencas @governanca
Funcionalidade: Gestão de licenças ambientais
  Como administrador de compliance ESG
  Quero cadastrar e manter as licenças ambientais das empresas
  Para garantir rastreabilidade e conformidade regulatória das operações

  @positivo @contrato
  Cenário: Listar as licenças ambientais cadastradas
    Dado que estou autenticado como "analyst"
    Quando envio uma requisição GET para "/api/licenses"
    Então o status da resposta deve ser 200
    E a resposta deve ser uma lista com ao menos 1 item
    E o corpo da resposta deve respeitar o contrato "schemas/license-list.json"

  @positivo
  Cenário: Filtrar licenças pelo status ACTIVE
    Dado que estou autenticado como "auditor"
    Quando envio uma requisição GET para "/api/licenses?status=ACTIVE"
    Então o status da resposta deve ser 200
    E o corpo da resposta deve respeitar o contrato "schemas/license-list.json"
    E todos os itens da lista devem ter o campo "status" igual a "ACTIVE"

  @positivo @contrato
  Cenário: Cadastrar uma licença ambiental com dados válidos
    Dado que estou autenticado como "admin"
    Quando envio uma requisição POST para "/api/licenses" com o corpo:
      """json
      {
        "code": "{codigoUnico}",
        "companyName": "EcoLog Brasil",
        "licenseType": "Operacao de Residuos",
        "status": "ACTIVE",
        "issuedAt": "{hoje}",
        "expiresAt": "{daquiUmAno}",
        "responsibleEmail": "compliance@ecolog.com.br"
      }
      """
    Então o status da resposta deve ser 201
    E o corpo da resposta deve respeitar o contrato "schemas/license.json"
    E o campo "code" da resposta deve ser "{codigoUnico}"
    E o campo "status" da resposta deve ser "ACTIVE"
    E o campo "expiresAt" da resposta deve ser "{daquiUmAno}"

  @positivo @contrato
  Cenário: Consultar uma licença pelo identificador
    Dado que existe uma licença ambiental cadastrada pelo administrador
    E que estou autenticado como "auditor"
    Quando envio uma requisição GET para "/api/licenses/{licencaId}"
    Então o status da resposta deve ser 200
    E o corpo da resposta deve respeitar o contrato "schemas/license.json"
    E o campo "id" da resposta deve ser "{licencaId}"
    E o campo "code" da resposta deve ser "{licencaCodigo}"

  @positivo @contrato
  Cenário: Atualizar o status de uma licença para SUSPENDED
    Dado que existe uma licença ambiental cadastrada pelo administrador
    E que estou autenticado como "admin"
    Quando envio uma requisição PUT para "/api/licenses/{licencaId}" com o corpo:
      """json
      {
        "code": "{licencaCodigo}",
        "companyName": "Empresa Verde BDD Atualizada",
        "licenseType": "Licenca de Operacao",
        "status": "SUSPENDED",
        "issuedAt": "{hoje}",
        "expiresAt": "{daquiUmAno}",
        "responsibleEmail": "esg@empresaverde.com.br"
      }
      """
    Então o status da resposta deve ser 200
    E o corpo da resposta deve respeitar o contrato "schemas/license.json"
    E o campo "status" da resposta deve ser "SUSPENDED"
    E o campo "companyName" da resposta deve ser "Empresa Verde BDD Atualizada"

  @positivo
  Cenário: Excluir uma licença sem vínculos e confirmar a remoção
    Dado que existe uma licença ambiental cadastrada pelo administrador
    E que estou autenticado como "admin"
    Quando envio uma requisição DELETE para "/api/licenses/{licencaId}"
    Então o status da resposta deve ser 204
    Quando envio uma requisição GET para "/api/licenses/{licencaId}"
    Então o status da resposta deve ser 404
    E a mensagem de erro deve ser "Licenca ambiental nao encontrada."

  @negativo @contrato
  Cenário: Rejeitar licença com data de expiração anterior à emissão
    Dado que estou autenticado como "admin"
    Quando envio uma requisição POST para "/api/licenses" com o corpo:
      """json
      {
        "code": "{codigoUnico}",
        "companyName": "Empresa Irregular",
        "licenseType": "Licenca Previa",
        "status": "ACTIVE",
        "issuedAt": "2026-06-01",
        "expiresAt": "2026-01-01",
        "responsibleEmail": "contato@irregular.com.br"
      }
      """
    Então o status da resposta deve ser 400
    E o corpo da resposta deve respeitar o contrato "schemas/error.json"
    E a mensagem de erro deve ser "A data de expiracao deve ser posterior a data de emissao."

  @negativo
  Cenário: Rejeitar licença com código já existente
    Dado que existe uma licença ambiental cadastrada pelo administrador
    E que estou autenticado como "admin"
    Quando envio uma requisição POST para "/api/licenses" com o corpo:
      """json
      {
        "code": "{licencaCodigo}",
        "companyName": "Empresa Duplicada",
        "licenseType": "Licenca de Operacao",
        "status": "ACTIVE",
        "issuedAt": "{hoje}",
        "expiresAt": "{daquiUmAno}",
        "responsibleEmail": "contato@duplicada.com.br"
      }
      """
    Então o status da resposta deve ser 400
    E o corpo da resposta deve respeitar o contrato "schemas/error.json"
    E a mensagem de erro deve ser "Ja existe uma licenca com o codigo informado."

  @negativo @contrato
  Cenário: Rejeitar cadastro com campos obrigatórios inválidos
    Dado que estou autenticado como "admin"
    Quando envio uma requisição POST para "/api/licenses" com o corpo:
      """json
      { "code": "", "responsibleEmail": "email-invalido" }
      """
    Então o status da resposta deve ser 400
    E o corpo da resposta deve respeitar o contrato "schemas/error.json"
    E a mensagem de erro deve ser "Payload invalido."
    E o campo "validations.code" da resposta deve existir
    E o campo "validations.responsibleEmail" da resposta deve existir

  @negativo @contrato
  Cenário: Consultar uma licença inexistente
    Dado que estou autenticado como "analyst"
    Quando envio uma requisição GET para "/api/licenses/999999"
    Então o status da resposta deve ser 404
    E o corpo da resposta deve respeitar o contrato "schemas/error.json"
    E a mensagem de erro deve ser "Licenca ambiental nao encontrada."

  @negativo
  Cenário: Atualizar uma licença inexistente
    Dado que estou autenticado como "admin"
    Quando envio uma requisição PUT para "/api/licenses/999999" com o corpo:
      """json
      {
        "code": "{codigoUnico}",
        "companyName": "Empresa Fantasma",
        "licenseType": "Licenca de Operacao",
        "status": "ACTIVE",
        "issuedAt": "{hoje}",
        "expiresAt": "{daquiUmAno}",
        "responsibleEmail": "contato@fantasma.com.br"
      }
      """
    Então o status da resposta deve ser 404
    E a mensagem de erro deve ser "Licenca ambiental nao encontrada."
