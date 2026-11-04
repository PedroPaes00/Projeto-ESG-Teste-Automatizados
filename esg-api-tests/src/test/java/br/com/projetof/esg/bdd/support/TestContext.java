package br.com.projetof.esg.bdd.support;

import io.cucumber.java.Scenario;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.http.Method;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Estado compartilhado entre os passos de UM cenario (uma instancia nova por cenario,
 * injetada pelo PicoContainer): credenciais, ultima resposta e variaveis.
 *
 * Variaveis podem ser usadas nos passos como {nome}, por exemplo "/api/licenses/{licencaId}".
 */
public class TestContext {

    private static final AtomicInteger SEQUENCE = new AtomicInteger();
    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    private final Map<String, String> variables = new LinkedHashMap<>();
    private String user;
    private String password;
    private Response response;
    private Scenario scenario;

    public TestContext() {
        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now();
        // Codigo unico por cenario: permite rodar os testes varias vezes sobre o mesmo banco
        String suffix = Long.toString(System.currentTimeMillis(), 36).toUpperCase() + "-" + SEQUENCE.incrementAndGet();

        variables.put("codigoUnico", "BDD-" + suffix);
        variables.put("hoje", today.toString());
        variables.put("daquiUmAno", today.plusYears(1).toString());
        variables.put("dataHoraFutura", now.plusDays(30).format(DATE_TIME));
        variables.put("dataHoraPassada", now.minusDays(30).format(DATE_TIME));
    }

    public void setScenario(Scenario scenario) {
        this.scenario = scenario;
    }

    public void authenticate(String user, String password) {
        this.user = user;
        this.password = password;
    }

    public void clearAuthentication() {
        this.user = null;
        this.password = null;
    }

    public void put(String name, String value) {
        variables.put(name, value);
    }

    public String get(String name) {
        String value = variables.get(name);
        if (value == null) {
            throw new IllegalStateException("Variavel '" + name + "' nao foi definida neste cenario.");
        }
        return value;
    }

    /** Substitui {variavel} pelo valor correspondente. */
    public String resolve(String text) {
        if (text == null) {
            return null;
        }
        String result = text;
        for (Map.Entry<String, String> entry : variables.entrySet()) {
            result = result.replace("{" + entry.getKey() + "}", entry.getValue());
        }
        return result;
    }

    public Response response() {
        if (response == null) {
            throw new IllegalStateException("Nenhuma requisicao foi enviada neste cenario.");
        }
        return response;
    }

    /** Envia a requisicao com o usuario autenticado no cenario e guarda a resposta. */
    public Response send(String method, String path, String body) {
        response = execute(user, password, method, path, body, "Requisicao");
        return response;
    }

    /** Envia uma requisicao de preparacao de dados sem alterar a resposta nem o usuario do cenario. */
    public Response sendAs(String user, String method, String path, String body) {
        return execute(user, ApiConfig.passwordFor(user), method, path, body, "Preparacao");
    }

    private Response execute(String user, String password, String method, String path, String body, String label) {
        String resolvedPath = resolve(path);
        String resolvedBody = resolve(body);

        RequestSpecification request = RestAssured.given()
                .baseUri(ApiConfig.baseUrl())
                .accept(ContentType.JSON);

        if (user != null) {
            // Preemptivo: a API nao envia o cabecalho WWW-Authenticate no 401
            request = request.auth().preemptive().basic(user, password);
        }
        if (resolvedBody != null) {
            request = request.contentType(ContentType.JSON).body(resolvedBody);
        }

        Response result = request.request(Method.valueOf(method.toUpperCase()), resolvedPath);
        attach(label, user, method, resolvedPath, resolvedBody, result);
        return result;
    }

    private void attach(String label, String user, String method, String path, String body, Response result) {
        if (scenario == null) {
            return;
        }
        StringBuilder text = new StringBuilder()
                .append(method.toUpperCase()).append(' ').append(ApiConfig.baseUrl()).append(path).append('\n')
                .append("Usuario: ").append(user == null ? "(sem credenciais)" : user).append('\n');
        if (body != null) {
            text.append("Corpo enviado:\n").append(body.strip()).append('\n');
        }
        text.append("\nStatus: ").append(result.statusCode()).append('\n')
                .append("Resposta:\n").append(result.asPrettyString());
        scenario.attach(text.toString(), "text/plain", label + " " + method.toUpperCase() + " " + path);
    }
}
