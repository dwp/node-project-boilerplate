FROM node:12.16.2-alpine@sha256:5646d1e5bc470500414feb3540186c02845db0e0e1788621c271fbf3a0c1830d

LABEL application="node-project-boilerplate"
LABEL maintainer="DWP Digital"
LABEL version="0.1.0"

RUN apk add --update --no-cache tini=0.18.0-r0 \
    ca-certificates=20191127-r1 \
    curl=7.67.0-r0

RUN mv "$(command -v tini)" /usr/local/bin/

ARG PROXY_CA_CERT
RUN echo "$PROXY_CA_CERT" > /usr/local/share/ca-certificates/proxy_ca.crt
RUN update-ca-certificates --verbose

WORKDIR /opt/harden

RUN curl -SL https://raw.githubusercontent.com/dwp/packer-infrastructure/master/docker-builder/scripts/base/harden.sh > harden.sh

RUN chmod +x /opt/harden/harden.sh \
    && sh /opt/harden/harden.sh \
    && rm -rf /opt/harden

USER node

WORKDIR /home/node/app

COPY package.json package-lock.json ./

RUN npm ci --only=production

COPY . .

ENTRYPOINT [ "tini", "--" ]

CMD [ "node", "src/main.js" ]
