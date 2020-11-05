FROM node:lts-alpine@sha256:dc9641311155f990b713df6ab2751c9dc487bd64dd66fb3a25dce673fd4167cc as node12

LABEL application="node-boilerplate-project"
LABEL maintainer="DWP Digital Engineering Practice"
LABEL version="0.1.0"

ARG PROXY_CA_CERT

RUN apk add --update --no-cache tini=0.18.0-r0 \
    ca-certificates=20191127-r1 \
    curl=7.67.0-r0 \
    &&  mv "$(command -v tini)" /usr/local/bin/

RUN echo "$PROXY_CA_CERT" > /usr/local/share/ca-certificates/proxy_ca.crt \
    && update-ca-certificates --verbose

RUN mkdir -p /root/harden \
    && curl -SL https://raw.githubusercontent.com/dwp/packer-infrastructure/master/docker-builder/scripts/base/harden.sh > /root/harden/harden.sh

RUN chmod +x /root/harden/harden.sh \
    && sh /root/harden/harden.sh \
    && rm -rf /root/harden

USER node

RUN mkdir -p /home/node/app

WORKDIR /home/node/app

COPY --chown=node:node package.json package-lock.json ./

RUN npm ci --only=production --no-optional --no-audit

COPY --chown=node:node . .

ENTRYPOINT [ "tini", "--" ]

CMD [ "node", "src/main.js" ]
