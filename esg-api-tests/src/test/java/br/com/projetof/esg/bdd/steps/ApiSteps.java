package br.com.projetof.esg.bdd.steps;

import br.com.projetof.esg.bdd.support.ApiConfig;
import br.com.projetof.esg.bdd.support.TestContext;
import io.cucumber.java.pt.Dado;
import io.cucumber.java.pt.Entao;
import io.cucumber.java.pt.Quando;
import io.restassured.module.jsv.JsonSchemaValidator;

import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.hamcrest.Matchers.notNullValue;

/**
 * Passos genericos de API: autenticacao, envio de requisicoes e validacoes de
 * status code, corpo JSON e contrato (JSON Schema).
 */
public class ApiSteps {

    private final TestContext context;

    public ApiSteps(TestContext context) {
        this.context = context;
    }

    // ---------- Autenticacao ----------

    @Dado("que estou autenticado como {string}")
    public void queEstouAutenticadoComo(String usuario) {
        context.authenticate(usuario, ApiConfig.passwordFor(usuario));
    }

    @Dado("que estou autenticado como {string} com a senha {string}")
    public void queEstouAutenticadoComOSenha(String usuario, String senha) {
        context.authenticate(usuario, senha);
    }

    @Dado("que não estou autenticado")
    public void queNaoEstouAutenticado() {
        context.clearAuthentication();
    }

    // ---------- Requisicoes ----------

    @Quando("envio uma requisição {word} para {string}")
    public void envioUmaRequisicao(String metodo, String caminho) {
        context.send(metodo, caminho, null);
    }

    @Quando("envio uma requisição {word} para {string} com o corpo:")
    public void envioUmaRequisicaoComOCorpo(String metodo, String caminho, String corpo) {
        context.send(metodo, caminho, corpo);
    }

    // ---------- Validacoes ----------

    @Entao("o status da resposta deve ser {int}")
    public void oStatusDaRespostaDeveSer(int statusEsperado) {
        context.response().then().statusCode(statusEsperado);
    }

    @Entao("o corpo da resposta deve respeitar o contrato {string}")
    public void oCorpoDeveRespeitarOContrato(String schema) {
        context.response().then().body(JsonSchemaValidator.matchesJsonSchemaInClasspath(schema));
    }

    @Entao("o campo {string} da resposta deve ser {string}")
    public void oCampoDaRespostaDeveSer(String campo, String valorEsperado) {
        Object valor = context.response().jsonPath().get(campo);
        assertThat("Valor do campo '" + campo + "'", String.valueOf(valor), equalTo(context.resolve(valorEsperado)));
    }

    @Entao("o campo {string} da resposta deve existir")
    public void oCampoDaRespostaDeveExistir(String campo) {
        Object valor = context.response().jsonPath().get(campo);
        assertThat("Campo '" + campo + "' ausente na resposta", valor, notNullValue());
    }

    @Entao("a mensagem de erro deve ser {string}")
    public void aMensagemDeErroDeveSer(String mensagem) {
        oCampoDaRespostaDeveSer("message", mensagem);
    }

    @Entao("a resposta deve ser uma lista com ao menos {int} item(s)")
    public void aRespostaDeveSerUmaLista(int quantidadeMinima) {
        List<Object> itens = context.response().jsonPath().getList("$");
        assertThat("A resposta deve ser uma lista JSON", itens, notNullValue());
        assertThat("Quantidade de itens na lista", itens.size(), greaterThanOrEqualTo(quantidadeMinima));
    }

    @Entao("todos os itens da lista devem ter o campo {string} igual a {string}")
    public void todosOsItensDevemTerOCampo(String campo, String valorEsperado) {
        List<Object> valores = context.response().jsonPath().getList(campo);
        assertThat("A resposta deve ser uma lista JSON", valores, notNullValue());
        String esperado = context.resolve(valorEsperado);
        for (Object valor : valores) {
            assertThat("Valor do campo '" + campo + "' em um dos itens", String.valueOf(valor), equalTo(esperado));
        }
    }

    @Entao("guardo o campo {string} da resposta como {string}")
    public void guardoOCampoComo(String campo, String variavel) {
        Object valor = context.response().jsonPath().get(campo);
        assertThat("Campo '" + campo + "' ausente na resposta", valor, notNullValue());
        context.put(variavel, String.valueOf(valor));
    }

    @Entao("o campo {string} da resposta deve ser {string} acrescido de {int}")
    public void oCampoDeveSerAcrescidoDe(String campo, String valorBase, int incremento) {
        long esperado = Long.parseLong(context.resolve(valorBase)) + incremento;
        Object valor = context.response().jsonPath().get(campo);
        assertThat("Campo '" + campo + "' ausente na resposta", valor, notNullValue());
        assertThat("Valor do campo '" + campo + "'", Long.parseLong(String.valueOf(valor)), equalTo(esperado));
    }
}
