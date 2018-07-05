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


###
 # Download the jar file to be signed.
 ##
JAR_PATH=~/tmp-$(date "+%Y%m%d.%H%M.%S").jar

curl -L --retry 5 -o ${JAR_PATH} "${JAR_URL}"


###
 # Sign the jar.
 ##
jarsigner -keystore ${HOME}/${KEYSTORE_FILENAME} \
        -storetype Luna \
        -storepass:env STORE_PASSWORD \
        -strict \
        ${JAR_PATH} ${KEY_ALIAS}


###
 # Proof that it worked! Check that signed jar contains .SF file, and validate.
 ##
{
  jar -tf ${JAR_PATH} | grep -E "META-INF/.*\.SF"
} || {
  echo "Signed jar does not contain .SF file"
  exit 1
}

{
  jarsigner -verify -verbose ${JAR_PATH}
} || {
  echo "Signed jar failed verification"
  exit 1
}

exit 0
