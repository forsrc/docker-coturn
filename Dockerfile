FROM ubuntu:19.10
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

#RUN apt-get -y install coturn certbot systemd sudo

#RUN systemctl enable coturn

RUN apt-get -y install systemd sudo wget gcc make git sqlite libsqlite3-dev libssl-dev libevent-dev libhiredis-dev libmysqlclient-dev libpq-dev pkg-config

RUN cd /tmp
#RUN wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
#RUN tar xvfz libevent-2.0.21-stable.tar.gz && cd libevent-2.0.21-stable && ./configure && make && make install
RUN git clone https://github.com/coturn/coturn
RUN mkdir -p /etc/coturn && cp -f coturn/examples/etc/turnserver.conf /etc/
RUN cd coturn && ./configure && make && make install
RUN mkdir -p /vaRUN mkdir -p /var/run/
RUN apt-get remove -y wget gcc make git
RUN rm -rf /tmp/*


#RUN sed -i 's/#TURNSERVER_ENABLED=1/TURNSERVER_ENABLED=1/g' /etc/default/coturn

RUN mkdir -p /etc/coturn
RUN openssl genrsa -out /etc/coturn/turn_server_pkey.pem 1024
RUN openssl req -new -key /etc/coturn/turn_server_pkey.pem -out /etc/coturn/turn_server.csr -subj /C=CN/O="forsrc"/OU="forsrc"/CN="coturn.forsrc.com"/ST="forsrc"/L="forsrc"
RUN openssl x509 -req -in /etc/coturn/turn_server.csr -signkey /etc/coturn/turn_server_pkey.pem -out /etc/coturn/turn_server_cert.pem

RUN sed -i 's@#cert=/usr\/local/etc/turn_server_cert.pem@cert=/etc/coturn/turn_server_cert.pem@g' /etc/turnserver.conf
RUN sed -i 's@#pkey=/usr/local/etc/turn_server_pkey.pem@pkey=/etc/coturn/turn_server_pkey.pem@g'  /etc/turnserver.conf
RUN sed -i 's@#server-name=blackdow.carleon.gov@server-name=coturn.forsrc.com@g'                  /etc/turnserver.conf
RUN sed -i 's@#realm=mycompany.org@realm=coturn.forsrc.com@g'                                             /etc/turnserver.conf
RUN sed -i 's@#user=username2:password2@user=forsrc:0xd667eb7aa3ebe3af48ee1c3330941e06@g'         /etc/turnserver.conf

RUN mkdir -p /var/lib/turn/
RUN mkdir -p /var/run/


RUN echo '#!/bin/bash'                        >  /docker-entrypoint.sh
RUN echo "if [ \"\${1:0:1}\" == '-' ]; then"  >> /docker-entrypoint.sh
RUN echo '  set -- turnserver "$@"'           >> /docker-entrypoint.sh
RUN echo 'fi'                                 >> /docker-entrypoint.sh
RUN echo 'exec $(eval "echo $@")'             >> /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV USER=forsrc
ARG PASSWD=forsrc
RUN apt-get update
RUN apt-get install -y sudo
RUN useradd -m --shell /bin/bash $USER && \
    echo "$USER:$PASSWD" | chpasswd && \
    echo "$USER ALL=(ALL) ALL" >> /etc/sudoers
RUN apt-get clean

RUN chown $USER:$USER /var/lib/turn/
RUN chown $USER:$USER /var/run/
RUN chown -R forsrc:forsrc /etc/coturn

WORKDIR /home/$USER
USER $USER


EXPOSE 3478 3478/udp
EXPOSE 5347 5347/udp

VOLUME ["/var/lib/coturn"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["--log-file=stdout", "-c", "/etc/turnserver.conf", "$COTURN_ARGS"]
