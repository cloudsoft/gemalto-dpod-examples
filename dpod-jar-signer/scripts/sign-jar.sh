#!/bin/bash -e

###
 # Input validation.
 ##
if [ -z "${STORE_PASSWORD}" ] ; then
  echo "STORE_PASSWORD environment variable must be set"
  exit 1;
fi
if [ -z "${JAR_URL}" ] ; then
  echo "JAR_URL environment variable must be set"
  exit 1;
fi
if [ -z "${KEYSTORE_FILENAME}" ] ; then
  echo "KEYSTORE_FILENAME environment variable must be set"
  exit 1;
fi
if ! [ -f "${HOME}/${KEYSTORE_FILENAME}" ] ; then
  echo "Keystore file does not exist (${HOME}/${KEYSTORE_FILENAME})"
  exit 1;
fi
if [ -z "${KEY_ALIAS}" ] ; then
  echo "KEY_ALIAS environment variable must be set"
  exit 1;
fi
if [ -z "${1}" ] ; then
  echo "Must pass the URL of a jar to be downloaded"
  exit 1;
fi


###
 # Download the jar file to be signed.
 ##
JAR_PATH=~/tmp-$(date "+%Y%m%d.%H%M.%S").jar

curl -L --retry 5 -o ${JAR_PATH} "${1}" 1>&2

if ! jar -tf ${JAR_PATH} > /dev/null; then
  >&2 echo Failed to download a jar file
  if file ${JAR_PATH} | grep 'ASCII' ; then
    >&2 echo "jar looks like a REST response:"
    >&2 cat jar
  fi
  exit 1
fi


###
 # Sign the jar.
 ##
jarsigner -keystore ${HOME}/${KEYSTORE_FILENAME} \
        -storetype Luna \
        -storepass:env STORE_PASSWORD \
        -strict \
        ${JAR_PATH} ${KEY_ALIAS} 1>&2


###
 # Output the jar to stdout
 ##
cat ${JAR_PATH}

exit 0
