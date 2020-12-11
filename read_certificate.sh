#!/bin/bash
IFS=''
#set -xe
#Script adapted from https://github.com/jsiegele/x509tojson/blob/master/x509tojson.sh
eval "$(jq -r '@sh "export URL=\(.url)"')"

CERT=$(echo "" | openssl s_client -connect $URL:443 2>/dev/null | openssl x509 -text 2>/dev/null)

getCert() {
  echo $CERT | sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p' | tr -d '\n'
}
getCertSubject() {
  echo $CERT | awk 'BEGIN{FS="Subject: "} NF==2{print $2}'
}
getCertSignatureAlgorithm() {
  echo $CERT | awk 'BEGIN{FS="Signature Algorithm: "} NF==2{print $2}'|head -n 1
}
getCertIssuer() {
  echo $CERT | awk 'BEGIN{FS="Issuer: "} NF==2{print $2}'
}
getCertNotBefore() {
  echo $CERT | awk 'BEGIN{FS="Not Before: "} NF==2{print $2}'
}
getCertNotAfter() {
  echo $CERT | awk 'BEGIN{FS="Not After : "} NF==2{print $2}'
}
getCertIssuerURL() {
  echo $CERT | awk 'BEGIN{FS="CA Issuers - URI:"} NF==2{print $2}'
}
getCertSerialNumber() {
  echo $CERT | sed -n '/Serial Number:/{n;p;}' | xargs
}
getCertSubjectKeyIdentifier() {
  echo $CERT | sed -n '/Subject Key Identifier:/{n;p;}' | xargs
}
getCertAuthorityKeyIdentifier() {
  echo $CERT | sed -n '/Authority Key Identifier:/{n;p;}' | xargs
}
getCommonName(){
    echo $1 | awk 'BEGIN{FS="(^| )CN( )*="} NF==2{print $2}' | awk -F, '{print $1}'| xargs
}
getOrganisation(){
    echo $1 | awk 'BEGIN{FS="(^| )O( )*="} NF==2{print $2}' | awk -F, '{print $1}'| xargs
}
getCountry(){
    echo $1 | awk 'BEGIN{FS="(^| )C( )*="} NF==2{print $2}' | awk -F, '{print $1}'| xargs
}

SUBJECT=$(getCertSubject)
ISSUER=$(getCertIssuer)

read -r -d '' JSON << EOM
{
  "id": "$(getCertSerialNumber)",
  "label": "$(getCommonName $SUBJECT)",
  "node": "$(hostname)",
  "date": "$(date)",
  "cert": "$(getCert)",
  "subject_raw": "$SUBJECT",
  "subject_common_name": "$(getCommonName $SUBJECT)",
  "subject_country": "$(getCountry $SUBJECT)",
  "subject_organization": "$(getOrganisation $SUBJECT)",
  "issuer_raw": "$ISSUER",
  "issuer_common_name": "$(getCommonName $ISSUER)",
  "issuer_country": "$(getCountry $ISSUER)",
  "issuer_organization": "$(getOrganisation $ISSUER)",
  "issuer_url": "$(getCertIssuerURL)",
  "serial_number": "$(getCertSerialNumber)",
  "not_before": "$(getCertNotBefore)",
  "not_after": "$(getCertNotAfter)",
  "sigalg": "$(getCertSignatureAlgorithm)",
  "authority_key_id": "$(getCertAuthorityKeyIdentifier)",
  "subject_key_id": "$(getCertSubjectKeyIdentifier)"
}
EOM

echo $JSON
