FROM debian
RUN apt update -y  && apt install -y ruby wget
RUN wget https://github.com/deb-s3/deb-s3/releases/download/0.11.3/deb-s3-0.11.3.gem && gem install deb-s3-0.11.3.gem
RUN wget https://github.com/mikefarah/yq/releases/download/v4.17.2/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
COPY --from=hairyhenderson/gomplate:v3 /gomplate /bin/gomplate
COPY control.gomplate /ro/control.gomplate
COPY build.sh /ro/build.sh
ENTRYPOINT ["/bin/sh", "/ro/build.sh"]