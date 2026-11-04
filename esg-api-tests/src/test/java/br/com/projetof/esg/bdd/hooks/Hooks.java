package br.com.projetof.esg.bdd.hooks;

import br.com.projetof.esg.bdd.support.ApiConfig;
import br.com.projetof.esg.bdd.support.TestContext;
import io.cucumber.java.Before;
import io.cucumber.java.BeforeAll;
import io.cucumber.java.Scenario;
import io.restassured.RestAssured;
import io.restassured.response.Response;

public class Hooks {

    private final TestContext context;

    public Hooks(TestContext context) {
        this.context = context;
    }

    /** Aguarda a API (e o Oracle) ficarem prontos antes do primeiro cenario. */
    @BeforeAll
    public static void aguardarApiDisponivel() {
        RestAssured.enableLoggingOfRequestAndResponseIfValidationFails();

        String healthUrl = ApiConfig.baseUrl() + "/actuator/health";
        long deadline = System.currentTimeMillis() + ApiConfig.waitTimeoutSeconds() * 1000L;
        System.out.println(">> Aguardando a API em " + healthUrl);

        while (true) {
            try {
                Response health = RestAssured.given().get(healthUrl);
                if (health.statusCode() == 200 && "UP".equals(health.jsonPath().getString("status"))) {
                    System.out.println(">> API disponivel (status UP)");
                    return;
                }
            } catch (Exception ignored) {
                // API ainda nao aceita conexoes
            }
            if (System.currentTimeMillis() > deadline) {
                throw new IllegalStateException("A API nao ficou disponivel em " + healthUrl
                        + " dentro de " + ApiConfig.waitTimeoutSeconds() + "s");
            }
            try {
                Thread.sleep(5000);
            } catch (InterruptedException interrupted) {
                Thread.currentThread().interrupt();
                throw new IllegalStateException("Espera pela API interrompida", interrupted);
            }
        }
    }

    @Before
    public void registrarCenario(Scenario scenario) {
        context.setScenario(scenario);
    }
}
