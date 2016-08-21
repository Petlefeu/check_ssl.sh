#!/bin/bash

FQDN_SERVER=$1
TMP_HEAD=/tmp/head.tmp
VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCLAIR="\\033[1;08m"
JAUNE="\\033[1;33m"
CYAN="\\033[1;36m"

curl https://${FQDN_SERVER}/ -ks -I -o $TMP_HEAD

# HSTS
# max-age=31536000; includeSubdomains; preload
HSTS=$(grep -i 'Strict-Transport-Security' /tmp/head.tmp)
if [ -z "${HSTS}" ]; then
    echo -e "${JAUNE}HSTS   ${ROUGE}header not present (NOT ok)${NORMAL}"
else
    echo -e "${JAUNE}HSTS   ${VERT}header present (OK)${NORMAL}, ${HSTS}"
fi

# ETag
ETAG=$(grep -i 'ETag' /tmp/head.tmp)
if [ -n "${ETAG}" ]; then
    echo -e "${JAUNE}ETAG   ${ROUGE}header present (NOT ok)${NORMAL}, ${ETAG}"
else
    echo -e "${JAUNE}ETAG   ${VERT}header not present (OK)${NORMAL}"
fi


# ALPN
# listen 443 ssl http2;
ALPN=$(echo -n | openssl s_client -alpn h2 -connect ${FQDN_SERVER}:443 2>&1 | grep ALPN)
if [ "${ALPN}" == "ALPN protocol: h2" ]; then
    echo -e "${JAUNE}ALPN   ${VERT}present (OK)${NORMAL}"
else
    echo -e "${JAUNE}ALPN   ${ROUGE}not present (NOT ok)${NORMAL}"
fi

# NPN
NPN=$(echo -n | openssl s_client -nextprotoneg h2 -connect ${FQDN_SERVER}:443 2>&1 | grep "Next protocol")
if [ "${NPN}" == "Next protocol: (1) h2" ]; then
    echo -e "${JAUNE}NPN    ${VERT}present (OK)${NORMAL}"
else
    echo -e "${JAUNE}NPN    ${ROUGE}not present (NOT ok)${NORMAL}"
fi


for http in $(echo GET HEAD OPTIONS DELETE PUT CONNECT)
do
    RET=$(curl -ks https://${FQDN_SERVER}/ -I -X ${http} | head -1 | grep 200)
    if [ -n "${RET}" ]; then
        echo -e "${JAUNE}HTTP Method : ${http}  ${VERT}joignable (OK)${NORMAL}"
    else
        echo -e "${JAUNE}HTTP Method : ${http}  ${JAUNE}injoignable (OK)${NORMAL}"
    fi
done

for http in $(echo TRACK CUSTOM)
do
    RET=$(curl -ks https://${FQDN_SERVER}/ -I -X ${http} | head -1 | grep 200)
    if [ -z "${RET}" ]; then
        echo -e "${JAUNE}HTTP Method : ${http}  ${VERT}injoignable (OK)${NORMAL}"
    else
        echo -e "${JAUNE}HTTP Method : ${http}  ${ROUGE}NOT ok${NORMAL}, ${RET}"
    fi
done