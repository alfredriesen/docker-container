FROM ubuntu:20.04

# timezone
RUN apt update && apt install -y tzdata; \
    apt clean;

# curl
RUN apt update && apt install -y curl; \
    apt clean;

#git
RUN apt update && apt install -y git; \
    apt clean;

# sshd
RUN mkdir /run/sshd; \
    apt install -y openssh-server; \
    sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config; \
    sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config; \
    apt clean;

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime'; \
    echo 'echo "root:${ROOT_PASSWORD}" | chpasswd'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entry_point.sh; \
    chmod +x /usr/local/bin/entry_point.sh;

#docker
RUN curl -fsSL https://get.docker.com | sh;

#docker-compose
RUN curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose; \
    chmod +x /usr/local/bin/docker-compose;

RUN echo "export APP_NAME=${APP_NAME}" >> /root/.profile

ENV TZ Europe/Berlin
ENV ROOT_PASSWORD root
ENV APP_NAME any
ENV SSH_PORT 51212

ENTRYPOINT ["entry_point.sh"]
CMD    ["/usr/sbin/sshd", "-D", "-e"]
