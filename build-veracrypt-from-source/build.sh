#!/bin/sh

BUILDDIR=tmp-veracrypt-build
SOURCE_URL=https://launchpad.net/veracrypt/trunk/1.22/+download/VeraCrypt_1.22_Source.tar.bz2
SOURCE_ARCHIVE=veracrypt.tar.bz2
SIGNATURE=../veracrypt-1.22-source.tar.bz2.asc
PUBKEY=EB559C7C54DDD393
PUBKEY_SERVER=hkp://ipv4.pool.sks-keyservers.net

# Fedora
if [ -x "$(which dnf 2>/dev/null)" ]; then
    dnf install curl gpg gcc make yasm wxGTK3 wxGTK3-devel fuse fuse-devel
else
    echo no package manager found
    exit
fi

mkdir $BUILDDIR
cd $BUILDDIR

# curl-options:
#  -s silent
#  -S show errors
#  -L follow redirects
#  -o output file
curl -Lo $SOURCE_ARCHIVE $SOURCE_URL

gpg --keyserver $PUBKEY_SERVER --recv-keys $PUBKEY
gpg --verify $SIGNATURE $SOURCE_ARCHIVE

tar -xf $SOURCE_ARCHIVE

# FROM builder-download as builder-veracrypt

# RUN apk update && apk add --no-cache \
#   g++ \
#   make \
#   yasm \
#   wxgtk-dev \
#   fuse-dev

# download software

# RUN curl -sSLo veracrypt.tar.bz2 https://launchpad.net/veracrypt/trunk/1.22/+download/VeraCrypt_1.22_Source.tar.bz2

# verify signatures

# RUN gpg --recv-keys EB559C7C54DDD393
# RUN gpg --verify verify/veracrypt-1.22-source.tar.bz2.asc veracrypt.tar.bz2

# install veracrypt

# WORKDIR veracrypt
# RUN tar -xf ../veracrypt.tar.bz2
# WORKDIR src
# RUN make \
#     TC_EXTRA_CFLAGS=-Wno-unused-const-variable \
#     TC_EXTRA_CXXFLAGS=-Wno-deprecated-declarations

########################################
### Final Stage                      ###
########################################

# FROM alpine:3.7
# RUN apk update && apk add --no-cache \
#   openjdk8-jre \
#   gtk+2.0 \
#   ttf-dejavu \
#   wxgtk \
#   fuse
