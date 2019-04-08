FROM node:latest AS builder

ARG ETHERPAD_VERSION=develop
ARG NODE_ENV=production
COPY . /opt/etherpad-lite

RUN /opt/etherpad-lite/bin/installDeps.sh

FROM node:latest

ENV NODE_ENV "production"
ENV EP_TITLE "Etherpad"
ENV EP_THEME "colibris"
ENV EP_DEFAULT_TEXT "Start writing..."
ENV EP_DEFAULT_LANG "en-us"
ENV EP_LISTEN "0.0.0.0"
ENV EP_PORT "9001"
ENV EP_ADMIN_USER "admin"
ENV EP_ADMIN_PASS "admin"
ENV EP_LOG_LEVEL "WARN"
ENV EP_ABIWORD_BIN "/usr/bin/abiword"
ENV EP_TIDY_BIN "/usr/bin/tidy"
ENV MYSQL_HOST ""
ENV MYSQL_PORT "3306"
ENV MYSQL_USER ""
ENV MYSQL_PASSWORD ""
ENV MYSQL_DATABASE ""

COPY --from=builder /opt/etherpad-lite /app
COPY ./docker/docker-entrypoint.sh /docker-entrypoint.sh
RUN apt-get update && \
    apt-get -y install abiword tidy mysql-client && \
    apt-get -y clean
WORKDIR /app

COPY ./docker/prepare-settings-workaround.sh /app/bin/prepareSettings.sh

EXPOSE ${EP_PORT}
ENTRYPOINT ["/bin/bash", "/docker-entrypoint.sh"]
CMD ["start"]
