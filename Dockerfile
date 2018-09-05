FROM alpine:latest

RUN apk update && \
    apk add --no-cache bash && \
    apk add --no-cache g++ && \
    apk add --no-cache make && \
    apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    pip install pipenv && \
    rm -r /root/.cache

WORKDIR /home

COPY ./collex-loader/config/ ./collex-loader/config/
COPY ./collex-loader/data/ ./collex-loader/data/
COPY ./collex-loader/*.py ./collex-loader/
COPY ./collex-loader/*.pyc ./collex-loader/

COPY ./social-test-setup/config/ ./social-test-setup/config/
COPY ./social-test-setup/data/ ./social-test-setup/data/
COPY ./social-test-setup/scripts/ ./social-test-setup/scripts/
COPY ./social-test-setup/*.py ./social-test-setup/
COPY ./social-test-setup/Makefile ./social-test-setup
COPY ./social-test-setup/Pipfile ./social-test-setup
COPY ./social-test-setup/Pipfile.lock ./social-test-setup
COPY ./social-test-setup/.env ./social-test-setup

WORKDIR /home/social-test-setup

ENV LANG=en_GB.UTF-8
RUN make install

CMD /bin/bash
