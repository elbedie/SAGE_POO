# ---- Estágio 1: Build (Compilação) ----
# Usamos uma imagem oficial do Maven (com Java 17) para compilar o projeto
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Define o diretório de trabalho dentro do contentor
WORKDIR /app

# Copia o ficheiro pom.xml primeiro para aproveitar o cache do Docker
COPY pom.xml .

# Copia o resto do código-fonte
COPY src ./src

# Roda o comando de build do Maven para gerar o .jar
# O "-DskipTests" acelera o build por não rodar os testes
RUN mvn clean install -DskipTests

# ---- Estágio 2: Run (Execução) ----
# Usamos uma imagem Java 17 "slim" (mais leve) apenas para rodar
FROM eclipse-temurin:17-jre-focal

# Define o diretório de trabalho
WORKDIR /app

# Copia o .jar que foi gerado no Estágio 1 para este novo contentor
# O nome do .jar tem que ser o mesmo do seu pom.xml (artifactId-version)
COPY --from=build /app/target/sage-0.0.1-SNAPSHOT.jar ./app.jar

# O Render espera que a aplicação rode na porta 10000
EXPOSE 10000

# Comando final para iniciar a sua aplicação na porta correta
CMD ["java", "-jar", "-Dserver.port=10000", "app.jar"]