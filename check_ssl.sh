#!/bin/bash

TMP_HEAD=/tmp/head.tmp
VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
JAUNE="\\033[1;33m"
VERSION=1.2.0

MAIN_HTTP_METHODS='
GET
HEAD
OPTIONS
DELETE
PUT
CONNECT'

OPTIONAL_HTTP_METHODS='
TRACE
TRACK
CUSTOM'

usage() {
    echo "$(basename "${0}")"' [-hv] -f <fqdn>'
    echo ""
}

if [ -z "${1}" ]; then
    usage >&2
    exit 1
fi

while getopts "f:hv" opt; do
  case $opt in
    f)
      FQDN_SERVER=$OPTARG
      ;;
    h)
      usage
      exit 0
      ;;
    v)
      echo 'Version '"${VERSION}"
      exit 0
      ;;
    \?)
      usage >&2
      exit 1
      ;;
    :)
      usage >&2
      exit 1
      ;;
  esac
done

trap 'rm -f "${TMP_HEAD}"' EXIT

touch $TMP_HEAD
curl https://"${FQDN_SERVER}"/ -ks -I -o $TMP_HEAD

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
ALPN=$(echo -n | openssl s_client -alpn h2 -connect "${FQDN_SERVER}":443 2>&1 | grep ALPN)
if [ "${ALPN}" == "ALPN protocol: h2" ]; then
    echo -e "${JAUNE}ALPN   ${VERT}present (OK)${NORMAL}"
else
    echo -e "${JAUNE}ALPN   ${ROUGE}not present (NOT ok)${NORMAL}"
fi

# NPN
NPN=$(echo -n | openssl s_client -nextprotoneg h2 -connect "${FQDN_SERVER}":443 2>&1 | grep "Next protocol")
if [ "${NPN}" == "Next protocol: (1) h2" ]; then
    echo -e "${JAUNE}NPN    ${VERT}present (OK)${NORMAL}"
else
    echo -e "${JAUNE}NPN    ${ROUGE}not present (NOT ok)${NORMAL}"
fi


for http in ${MAIN_HTTP_METHODS}
do
    RET=$(curl -ks https://"${FQDN_SERVER}"/ -I -X "${http}" --max-time 10 --connect-timeout 10 | head -1 | grep '200\|301')
    if [ -n "${RET}" ]; then
        echo -e "${JAUNE}HTTP Method : ${http}  ${VERT}enable (OK)${NORMAL}"
    else
        echo -e "${JAUNE}HTTP Method : ${http}  ${VERT}disable (OK)${NORMAL}"
    fi
done

for http in ${OPTIONAL_HTTP_METHODS}
do
    RET=$(curl -ks https://"${FQDN_SERVER}"/ -I -X "${http}" --max-time 10 --connect-timeout 10 | head -1 | grep '200\|301')
    if [ -z "${RET}" ]; then
        echo -e "${JAUNE}HTTP Method : ${http}  ${VERT}disable (OK)${NORMAL}"
    else
        echo -e "${JAUNE}HTTP Method : ${http}  ${ROUGE}NOT ok${NORMAL}, ${RET}"
    fi
done
