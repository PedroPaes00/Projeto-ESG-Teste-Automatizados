# Imagem do executor dos testes BDD (Cucumber + RestAssured).
# Nao precisa de Java/Maven instalados na maquina: tudo roda dentro do container.
FROM maven:3.9.9-eclipse-temurin-21

WORKDIR /tests

# Camada separada para cache das dependencias (so e refeita quando o pom.xml muda)
COPY pom.xml .
RUN mvn -q -B dependency:go-offline

COPY src ./src

# Dentro da rede do Docker Compose a API responde pelo nome do servico "app"
ENV API_BASE_URL=http://app:8080 \
    API_WAIT_TIMEOUT=300

# Os relatorios ficam em /tests/target/cucumber-reports (montado como volume no Compose)
CMD ["mvn", "-B", "test"]
