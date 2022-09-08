FROM python:latest

ARG SMS_GATE_LOGIN
ARG SMS_GATE_PASSWORD

ENV SMS_GATE_LOGIN=${SMS_GATE_LOGIN}
ENV SMS_GATE_PASSWORD=${SMS_GATE_PASSWORD}
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# ADD RootCA.crt /usr/local/share/ca-certificates
# ADD IntermediateCA.crt /usr/local/share/ca-certificates
RUN update-ca-certificates && \
    python -m pip install requests

WORKDIR /app

COPY web_server.py .

ENTRYPOINT ["python3", "web_server.py"]
