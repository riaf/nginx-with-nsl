#!/bin/sh

NGINX="nginx-1.8.0"
BUILD_DIR="/tmp/build-$NGINX"

echo 'deb http://debian-mirror.sakura.ne.jp/debian jessie main
deb-src http://debian-mirror.sakura.ne.jp/debian jessie main

deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main

deb http://debian-mirror.sakura.ne.jp/debian jessie-updates main
deb-src http://debian-mirror.sakura.ne.jp/debian jessie-updates main' > /etc/apt/sources.list

apt-get update
apt-get install -y dpkg-dev debhelper libssl-dev imagemagick libmagickwand-dev unzip # graphicsmagick-libmagick-dev-compat
apt-get autoremove -y

curl -LOs http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key

echo 'deb http://nginx.org/packages/debian/ jessie nginx
deb-src http://nginx.org/packages/debian/ jessie nginx' > /etc/apt/sources.list.d/nginx.list

apt-get update

mkdir -p $BUILD_DIR; cd $BUILD_DIR
apt-get source nginx
apt-get build-dep nginx

curl -LOs https://github.com/cubicdaiya/ngx_small_light/archive/master.zip
mkdir -p $BUILD_DIR/$NGINX/debian/modules
unzip -d $BUILD_DIR/$NGINX/debian/modules/ master.zip
cd $BUILD_DIR/$NGINX/debian/modules/ngx_small_light-master
PATH=/usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16:$PATH ./setup

cd $BUILD_DIR/$NGINX
patch -u debian/rules < /vagrant/patches/rules.patch
dpkg-buildpackage -b

cp ../*.deb /vagrant

