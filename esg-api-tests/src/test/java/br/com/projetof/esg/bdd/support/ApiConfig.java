package br.com.projetof.esg.bdd.support;

/**
 * Configuracao dos testes lida de propriedades do sistema (-Dapi.baseUrl=...)
 * ou variaveis de ambiente (API_BASE_URL=...), com padroes do ambiente local.
 */
public final class ApiConfig {

    private ApiConfig() {
    }

    public static String baseUrl() {
        return read("api.baseUrl", "API_BASE_URL", "http://localhost:8080");
    }

    public static int waitTimeoutSeconds() {
        return Integer.parseInt(read("api.waitTimeout", "API_WAIT_TIMEOUT", "300"));
    }

    public static String passwordFor(String user) {
        return switch (user) {
            case "admin" -> read("api.adminPassword", "ADMIN_PASSWORD", "Admin@123");
            case "auditor" -> read("api.auditorPassword", "AUDITOR_PASSWORD", "Auditor@123");
            case "analyst" -> read("api.analystPassword", "ANALYST_PASSWORD", "Analyst@123");
            default -> throw new IllegalArgumentException("Usuario desconhecido: " + user);
        };
    }

    private static String read(String property, String environmentVariable, String defaultValue) {
        String value = System.getProperty(property);
        if (value == null || value.isBlank()) {
            value = System.getenv(environmentVariable);
        }
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
