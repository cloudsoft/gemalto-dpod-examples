#!/bin/bash -e

if ! [ -f ${CRYPTO_LIB} ] ; then
  echo "Could not find ${CRYPTO_LIB}"
  exit 1;
fi

echo "Stub code - what does it mean to 'install' your service (configuring it to use dpod)?"
exit 0
