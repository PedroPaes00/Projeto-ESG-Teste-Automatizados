# language: pt
@dashboard @governanca
Funcionalidade: Dashboard de indicadores ESG
  Como gestor de sustentabilidade
  Quero consultar indicadores consolidados de licenças, alertas e auditorias
  Para acompanhar a situação de compliance ambiental da organização

  @positivo @contrato
  Cenário: Consultar o resumo de indicadores
    Dado que estou autenticado como "analyst"
    Quando envio uma requisição GET para "/api/dashboard/summary"
    Então o status da resposta deve ser 200
    E o corpo da resposta deve respeitar o contrato "schemas/dashboard-summary.json"

  @positivo
  Cenário: Indicador de alertas abertos reflete um novo alerta registrado
    Dado que existe uma licença ambiental cadastrada pelo administrador
    E que estou autenticado como "analyst"
    E envio uma requisição GET para "/api/dashboard/summary"
    E guardo o campo "openAlerts" da resposta como "alertasAbertosAntes"
    Quando um novo alerta de compliance em aberto é registrado para essa licença
    E envio uma requisição GET para "/api/dashboard/summary"
    Então o status da resposta deve ser 200
    E o campo "openAlerts" da resposta deve ser "{alertasAbertosAntes}" acrescido de 1
