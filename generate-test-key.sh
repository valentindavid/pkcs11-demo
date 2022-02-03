#!/bin/bash

# This generates 3 key and certificates for a fake smartcard to be
# used with QEMU.
# It also generates a CA certificate and key to sign them.
#
# To enable the smartcard in QEMU, use
#
# -usb -device usb-ccid
# -device ccid-card-emulated,backend=certificates,db=sql:${FAKE_SMARTCARD_DIR},cert1=id-cert,cert2=signing-cert,cert3=encryption-cert

set -e

FAKE_SMARTCARD_DIR="${PWD}/fake_smartcard"
COMMON_NAME=example.com

run_certutil() {
    NOISE="${FAKE_SMARTCARD_DIR}"/noise.dat
    head -c50 /dev/random >"${NOISE}"
    certutil -S -d sql:"${FAKE_SMARTCARD_DIR}" -z "${NOISE}" "$@"
    sleep .1
    rm "${NOISE}"
}

if ! [ -d "${FAKE_SMARTCARD_DIR}" ]; then
    mkdir -p "${FAKE_SMARTCARD_DIR}"
    certutil -N -d sql:"${FAKE_SMARTCARD_DIR}" --empty-password
    run_certutil -s "CN=Fake CA" -x -t TC,TC,TC -n fake-ca --nsCertType sslCA
    run_certutil -t ,, -s "CN=${COMMON_NAME}" -n id-cert -c fake-ca
    run_certutil -t ,, -s "CN=${COMMON_NAME}" --nsCertType smime -n signing-cert -c fake-ca
    run_certutil -t ,, -s "CN=${COMMON_NAME}" --nsCertType sslClient,sslServer -n encryption-cert -c fake-ca

    certutil -d sql:"${FAKE_SMARTCARD_DIR}" -L -a -n fake-ca >"${FAKE_SMARTCARD_DIR}/ca-cert.pem"
    certutil -d sql:"${FAKE_SMARTCARD_DIR}" -L -a -n encryption-cert >"${FAKE_SMARTCARD_DIR}/cert.pem"
    cat "${FAKE_SMARTCARD_DIR}/cert.pem" "${FAKE_SMARTCARD_DIR}/ca-cert.pem" >"${FAKE_SMARTCARD_DIR}/chain.pem"
fi
