```
sudo docker run -d --network=host --hostname coturn.forsrc.com forsrc/coturn

sudo docker run -d -p 3478:3478 -p 5347:5347 -p 49160-49200:49160-49200/udp --name coturn  --hostname coturn.forsrc.com \
                forsrc/coturn -n --log-file=stdout -f -v -r coturn.forsrc.com\
                              --external-ip='$(curl -4 https://icanhazip.com 2>/dev/null)' \
                              --min-port=49160 --max-port=49200 \
                              -c /etc/turnserver.conf

sudo docker run -d -p 3478:3478 -p 5347:5347 -p 8080:8080 -p 49160-49200:49160-49200/udp --name coturn --hostname coturn.forsrc.com \
                forsrc/coturn -n --log-file=stdout -f -v -a \
                              -r coturn.forsrc.com -u forsrc:0xd667eb7aa3ebe3af48ee1c3330941e06 \
                              --external-ip='$(curl -4 https://icanhazip.com 2>/dev/null)' \
                              --min-port=49160 --max-port=49200 \
                              --web-admin-listen-on-workers --web-admin --web-admin-ip=0.0.0.0 --web-admin-port=8080 \
                              -c /etc/turnserver.conf


sudo docker exec coturn turnutils_uclient -u forsrc -w forsrc -v -y coturn.forsrc.com

```
