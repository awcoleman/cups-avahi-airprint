#!/bin/sh
set -e
set -x

# Get HP2600n
SHA256_foo2zjs=25cec22c1c503c4a25bf91cddb5f5130d2183c8a6de498c82c23c295aef9fc48
mkdir -p ./resources
if [ ! -f ./resources/foo2zjs.tar.gz ]; then
  curl -sLo ./resources/foo2zjs.tar.gz http://foo2zjs.rkkda.com/foo2zjs.tar.gz
  if ! echo "${SHA256_foo2zjs} ./resources/foo2zjs.tar.gz" | sha256sum -c -; then
    echo "Unexpected checksum from http://foo2zjs.rkkda.com/foo2zjs.tar.gz. Exiting."
    exit 1
  fi
else
  echo "Using included foo2zjs.tar.gz instead of redownloading from foo2zjs.rkkda.com."
fi
tar zxf ./resources/foo2zjs.tar.gz && cd ./foo2zjs
make
if [ -f ../resources/hpclj2600n.tar.gz ] && [ -f ../resources/km2430.tar.gz ] && [ -f ../resources/hp1215.tar.gz ]; then
  echo "Using included ICM resource tgz files instead of redownloading from foo2zjs.rkkda.com."
  tar xzvf ../resources/hpclj2600n.tar.gz
  tar xzvf ../resources/km2430.tar.gz "km2430_2.icm"
  tar xzvf ../resources/hp1215.tar.gz
else
  echo "ICM resource tgz files not found, using getweb 2600n to download."
  ./getweb 2600n
fi
make install

mkdir -p /etc/cups
mkdir -p /etc/avahi/services
cp -p ../resources/savedconfig/printers.conf /etc/cups/
cp -p ../resources/savedservices/AirPrint-2600n.service /etc/avahi/services/