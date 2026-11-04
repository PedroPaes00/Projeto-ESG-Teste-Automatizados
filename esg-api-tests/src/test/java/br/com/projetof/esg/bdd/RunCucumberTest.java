package br.com.projetof.esg.bdd;

import org.junit.platform.suite.api.ConfigurationParameter;
import org.junit.platform.suite.api.IncludeEngines;
import org.junit.platform.suite.api.SelectClasspathResource;
import org.junit.platform.suite.api.Suite;

import static io.cucumber.junit.platform.engine.Constants.GLUE_PROPERTY_NAME;
import static io.cucumber.junit.platform.engine.Constants.PLUGIN_PROPERTY_NAME;

/**
 * Ponto de entrada dos testes BDD.
 * Executa todos os arquivos .feature em src/test/resources/features
 * e gera relatorios HTML, JSON e JUnit XML em target/cucumber-reports.
 *
 * Filtrar por tag: mvn test -Dcucumber.filter.tags="@licencas and not @negativo"
 */
@Suite
@IncludeEngines("cucumber")
@SelectClasspathResource("features")
@ConfigurationParameter(key = GLUE_PROPERTY_NAME, value = "br.com.projetof.esg.bdd")
@ConfigurationParameter(key = PLUGIN_PROPERTY_NAME, value = "pretty,"
        + "summary,"
        + "html:target/cucumber-reports/cucumber.html,"
        + "json:target/cucumber-reports/cucumber.json,"
        + "junit:target/cucumber-reports/cucumber.xml")
public class RunCucumberTest {
}
