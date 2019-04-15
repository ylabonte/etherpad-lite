FROM node:latest AS builder

ARG ETHERPAD_VERSION=develop
ARG NODE_ENV=production
COPY . /opt/etherpad-lite

WORKDIR /opt/etherpad-lite/src
RUN ../bin/installDeps.sh

FROM node:alpine as stage2

COPY --from=builder /opt/etherpad-lite /opt/etherpad-lite
WORKDIR /opt/etherpad-lite
RUN apk update && apk add alpine-sdk python
RUN npm install bcrypt

FROM node:alpine

ENV NODE_ENV "production"
ENV EP_TITLE "Etherpad"
ENV EP_THEME "colibris"
ENV EP_DEFAULT_TEXT "Start writing..."
ENV EP_DEFAULT_LANG "en-us"
ENV EP_LISTEN "0.0.0.0"
ENV EP_PORT "9001"
ENV EP_ADMIN_USER "admin"
ENV EP_ADMIN_PASS "admin"
ENV EP_LOG_LEVEL "INFO"
ENV EP_ABIWORD_BIN "/usr/bin/abiword"
ENV EP_TIDY_BIN "/usr/bin/tidy"
ENV EP_MYSQL_HOST ""
ENV EP_MYSQL_PORT "3306"
ENV EP_MYSQL_USER "etherpad"
ENV EP_MYSQL_PASSWORD "etherpad"
ENV EP_MYSQL_DATABASE "etherpad_lite_db"

COPY --from=stage2 /opt/etherpad-lite /app
COPY ./docker/docker-entrypoint.sh /docker-entrypoint.sh
RUN apk update &&\
    apk add abiword abiword-plugin-command mysql-client tidyhtml &&\
    rm -rf /var/cache/apk/*

COPY ./docker/prepare-settings-workaround.sh /app/bin/prepareSettings.sh
WORKDIR /app

EXPOSE ${EP_PORT}
ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]
CMD ["start"]
