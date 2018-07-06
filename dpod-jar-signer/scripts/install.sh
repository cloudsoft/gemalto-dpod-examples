#!/bin/bash -e

###
 # Input validation.
 ##
if ! [ -d "${CRYPTO_HOME}" ] ; then
  echo "Could not find ${CRYPTO_HOME}"
  exit 1;
fi
if [ -z "${STORE_PASSWORD}" ] ; then
  echo "STORE_PASSWORD environment variable must be set"
  exit 1;
fi
if [ -z "${PARTITION_NAME}" ] ; then
  echo "PARTITION_NAME environment variable must be set"
  exit 1;
fi
if [ -z "${KEYSTORE_FILENAME}" ] ; then
  echo "KEYSTORE_FILENAME environment variable must be set"
  exit 1;
fi
if [ -z "${KEY_ALIAS}" ] ; then
  echo "KEY_ALIAS environment variable must be set"
  exit 1;
fi


###
 # Workaround for old CentOS 7 VMs.
 # See https://issues.apache.org/jira/browse/BROOKLYN-588
 ##
sudo yum update -y curl nss


###
 # Install Java.
 ##
sudo yum install -y java-1.8.0-openjdk-devel

export JRE_HOME=/usr/lib/jvm/jre
export JRE_SECURITY_FILE=${JRE_HOME}/lib/security/java.security

if ! [ -d "${JRE_HOME}" ] ; then
  echo "Could not find directory ${JRE_HOME}"
  exit 1;
fi


###
 # Configure Java with Luna security provider.
 ##
sudo cp ${CRYPTO_HOME}/jsp/LunaProvider.jar ${JRE_HOME}/lib/ext/
sudo cp ${CRYPTO_HOME}/jsp/64/libLunaAPI.so ${JRE_HOME}/lib/ext/

echo "security.provider.10=com.safenetinc.luna.provider.LunaProvider" | sudo tee -a ${JRE_SECURITY_FILE}


###
 # Create Luna keystore file.
 ##
tee ${HOME}/${KEYSTORE_FILENAME} <<-EOF
tokenlabel:${PARTITION_NAME}
EOF


###
 # Generate a key, to be used later for jar-signing.
 ##
keytool -genkeypair -alias ${KEY_ALIAS} -keyalg RSA -sigalg SHA256withRSA \
        -keysize 2048 \
        -dname "CN=Aled Sage, OU=Engineering, O=Cloudsoft, L=Edinburgh, ST=Midlothian, C=GB" \
        -storetype Luna \
        -keystore ${HOME}/${KEYSTORE_FILENAME} \
        -keypass ${STORE_PASSWORD} \
        -storepass:env STORE_PASSWORD \
        -noprompt

exit 0
