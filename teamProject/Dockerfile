# 1. 기반 이미지 설정: 경량화된 OpenJDK 17을 사용합니다.
FROM openjdk:17-jdk-slim

# 2. 작업 디렉토리 설정: 컨테이너 내부의 작업 공간을 /app으로 지정합니다.
WORKDIR /app

# 3. Gradle 빌드 환경 복사 및 의존성 다운로드:
# 캐시를 활용하여 빌드 속도를 높입니다.
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .

# 의존성 다운로드 및 빌드
# RUN ./gradlew dependencies --no-daemon
RUN ./gradlew bootJar --no-daemon

# 4. 최종 JAR 파일 복사:
# 빌드된 JAR 파일을 'app.jar'라는 이름으로 컨테이너에 복사합니다.
COPY build/libs/*.jar app.jar

# 5. 애플리케이션 실행 명령어:
# 컨테이너 시작 시 'java -jar app.jar' 명령어를 실행합니다.
ENTRYPOINT ["java", "-jar", "app.jar"]

# 6. 포트 노출:
# 애플리케이션이 외부와 통신할 포트 번호를 지정합니다.
EXPOSE 8080