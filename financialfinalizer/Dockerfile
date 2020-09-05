  
# Use a minimal image as parent
FROM openjdk:8-jdk-alpine
#FROM openjdk:latest

# Environment variables

# init
RUN apk -U upgrade --update && \
    apk add curl && \
    apk add ttf-dejavu && \
    apk add python3 && \
    curl -o /tmp/get-pip.py "https://bootstrap.pypa.io/get-pip.py" \
    && python3 /tmp/get-pip.py \
    && pip install xlrd && \
    apk add bash

WORKDIR /

COPY *.jar /


EXPOSE 8080

CMD ["java", "-jar", "FinancialProcessor-0.0.1-SNAPSHOT.jar"]
