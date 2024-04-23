FROM croservices/cro-http-websocket:0.8.9
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN zef install --deps-only . && raku -c -I. service.raku
ENV DISTRIBUTIONS_STORAGE_HOST="0.0.0.0" DISTRIBUTIONS_STORAGE_PORT="10000"
EXPOSE 10000
CMD raku -I. service.raku
