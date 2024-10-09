

FROM debian:latest

LABEL maintainer="Haytham Elganiny <elganiny.haytham@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y --no-install-recommends \
  build-essential \
  uuid-dev \
  git \
  gzip \
  libarchive-dev \
  libsodium-dev \
  libcurl4-openssl-dev \
  curl \
  libpq-dev \
  libssl-dev \
  postgresql \
  npm \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash content-storage

USER content-storage

RUN git clone https://github.com/rakudo/rakudo.git /tmp/rakudo && cd /tmp/rakudo && \
  perl Configure.pl --gen-nqp --gen-moar --backends=moar --prefix=/home/content-storage/rakudo && \
  make && \
  make install

ENV PATH="/home/content-storage/rakudo/bin:${PATH}"
RUN git clone https://github.com/hythm7/Pakku.git /tmp/Pakku && \
  cd /tmp/Pakku && \
  raku -I. bin/pakku add .

ENV PATH="/home/content-storage/rakudo/bin:/home/content-storage/rakudo/share/perl6/site/bin:${PATH}"

WORKDIR /home/content-storage
RUN mkdir app
COPY . app

WORKDIR /home/content-storage/app

RUN npm install

RUN npm run build

ENV RAKULIB="."
RUN pakku add deps only exclude Test::ContainerizedService notest . && raku -c -I. service.raku

ENV CONTENT_STORAGE_HOST="0.0.0.0" CONTENT_STORAGE_PORT="20000"

EXPOSE 20000

CMD [ "raku", "-I.", "service.raku" ]
