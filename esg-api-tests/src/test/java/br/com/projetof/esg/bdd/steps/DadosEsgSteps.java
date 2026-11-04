package br.com.projetof.esg.bdd.steps;

import br.com.projetof.esg.bdd.support.TestContext;
import io.cucumber.java.pt.Dado;
import io.cucumber.java.pt.Quando;
import io.restassured.response.Response;

/**
 * Passos de preparacao de dados do dominio ESG (licencas e alertas).
 * Usam o perfil admin sem alterar o usuario nem a resposta do cenario.
 */
public class DadosEsgSteps {

    private final TestContext context;

    public DadosEsgSteps(TestContext context) {
        this.context = context;
    }

    @Dado("que existe uma licença ambiental cadastrada pelo administrador")
    public void queExisteUmaLicencaCadastrada() {
        String codigo = context.get("codigoUnico") + "-L";
        String corpo = """
                {
                  "code": "%s",
                  "companyName": "Empresa Verde BDD",
                  "licenseType": "Licenca de Operacao",
                  "status": "ACTIVE",
                  "issuedAt": "%s",
                  "expiresAt": "%s",
                  "responsibleEmail": "esg@empresaverde.com.br"
                }
                """.formatted(codigo, context.get("hoje"), context.get("daquiUmAno"));

        Response resposta = context.sendAs("admin", "POST", "/api/licenses", corpo);
        resposta.then().statusCode(201);

        context.put("licencaId", String.valueOf(resposta.jsonPath().getLong("id")));
        context.put("licencaCodigo", codigo);
    }

    @Dado("que existe um alerta de compliance em aberto para essa licença")
    public void queExisteUmAlertaEmAberto() {
        registrarAlertaEmAberto();
    }

    @Quando("um novo alerta de compliance em aberto é registrado para essa licença")
    public void umNovoAlertaERegistrado() {
        registrarAlertaEmAberto();
    }

    private void registrarAlertaEmAberto() {
        String corpo = """
                {
                  "licenseId": %s,
                  "severity": "HIGH",
                  "message": "Alerta BDD: renovacao da licenca ambiental pendente",
                  "resolved": false
                }
                """.formatted(context.get("licencaId"));

        Response resposta = context.sendAs("admin", "POST", "/api/alerts", corpo);
        resposta.then().statusCode(201);

        context.put("alertaId", String.valueOf(resposta.jsonPath().getLong("id")));
    }
}
