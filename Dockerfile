FROM node:lts-alpine@sha256:b2da3316acdc2bec442190a1fe10dc094e7ba4121d029cb32075ff59bb27390a

LABEL application="node-boilerplate-project"
LABEL maintainer="DWP Digital Engineering Practice"
LABEL version="0.1.0"

ARG PROXY_CA_CERT

RUN apk add --update --no-cache tini=0.18.0-r0 \
    ca-certificates=20191127-r2 \
    curl=7.67.0-r3 \
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
