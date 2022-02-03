## Contents

### opensc

This is a snap to be built with snapcraft.
This provides a pkcs11 module for CCID smartcards

p11-kit server runs as service as part of the snap.  It exports its
socket through a socket unit but also in a slot p11-kit-service with
interface "content".

### nginx-pkcs

This is a snap to be built with snapcraft.
A web-server with the possibility to use a pkcs11 module

It expects you to connect it to opensc.

```
snap connect nginx-pkcs:p11-kit-service opensc:p11-kit-service
```

It starts with a local snake oil key.

To configure a pkcs11 private key for the SSL configuration, you need
to set "name" for the "common name" of the certificate, "cert" for
the certificate chain, and "key" for the pkcs11 key.

For example:

```
snap set nginx-pkcs name=example.com key=pkcs11:token=example.com cert="$(chain.pem)"
```

Then restart `nginx-pkcs`.

### generate-test-key.sh

This is an example of script to generate keys for an emulated
smartcard for QEMU. Instruction on the command line for QEMU are in
the script.
