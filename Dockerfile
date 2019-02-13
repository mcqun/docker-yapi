FROM node:11-alpine

RUN set -ex \
  && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/' /etc/apk/repositories \
  && apk update \
  && apk add --no-cache git curl make tar g++\
  && apk add --no-cache --purge -uU python2 python2-dev py-setuptools py-virtualenv \
  && if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python2.7 /usr/bin/python; fi \
  && if [[ ! -e /usr/bin/python-config ]]; then ln -sf /usr/bin/python2.7-config /usr/bin/python-config; fi \
  && if [[ ! -e /usr/bin/easy_install ]];  then ln -sf /usr/bin/easy_install-2.7 /usr/bin/easy_install; fi \
  # Install and upgrade Pip
  && easy_install pip \
  && pip install --upgrade pip \
  && if [[ ! -e /usr/bin/pip ]]; then ln -sf /usr/bin/pip2.7 /usr/bin/pip; fi; \
  rm -rf /var/cache/apk/* /tmp/* \
  && addgroup -g 82 -S www-data \
  && adduser -u 82 -D -S -G www-data www-data \
  && mkdir /yapi \
  && chown -R www-data:www-data /yapi \
  && npm i -g node-gyp yapi-cli

COPY --chown=www-data:www-data config.json /yapi
COPY run.sh /yapi

RUN chmod +x /yapi/run.sh

USER www-data

WORKDIR /yapi

ENV YAPI_VERSION=1.5.0

# COPY --chown=www-data:www-data yapi.tar.gz /yapi
RUN mkdir -p vendors \
  && curl -SL "https://github.com/YMFE/yapi/archive/v${YAPI_VERSION}.tar.gz" -o yapi.tar.gz \
  && tar -xvf yapi.tar.gz -C vendors  --strip-components=1 \
  && rm -rf yapi.tar.gz 

WORKDIR /yapi/vendors

EXPOSE 8866

ENTRYPOINT [ "/yapi/run.sh" ]
