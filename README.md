```
sudo docker run -d --network=host forsrc/coturn

sudo docker run -itd -p 3478:3478 -p 5347:5347 -p 49160-49200:49160-49200/udp --name coturn \
           forsrc/coturn -n --log-file=stdout -f -v -r coturn.forsrc.com\
                            --external-ip='$(curl -4 https://icanhazip.com 2>/dev/null)' \
                            --min-port=49160 --max-port=49200 \
                            -c /etc/turnserver.conf

sudo docker run --rm forsrc/coturn turnutils_uclient -u forsrc -w forsrc -v -y 172.17.0.3

```
