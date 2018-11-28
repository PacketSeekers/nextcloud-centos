#!/bin/bash

IMAGE_NAME="centos-php-fpm:latest"

ctr=$(buildah from centos)
buildah run $ctr -- yum update -y
buildah run $ctr -- yum install -y centos-release-scl epel-release yum-utils
buildah run $ctr -- yum install -y rh-php70 rh-php70-php rh-php70-php-fpm

# FIXME: is this still required?
# This needs to be done - because php-fpm is creating pid file in this location
# Why this isn't done by rpm package is mystery
#buildah run $ctr mkdir -p /run/php-fpm

buildah config --author 'Jiri Konecny' $ctr
buildah config --port 9000 $ctr
buildah config --cmd '/opt/rh/rh-php70/root/sbin/php-fpm -F' $ctr

buildah commit --rm $ctr $IMAGE_NAME
