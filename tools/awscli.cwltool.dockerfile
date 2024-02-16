FROM debian:12-slim
RUN apt-get update && apt-get install -qy --no-install-recommends awscli ca-certificates
