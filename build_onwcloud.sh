#!/bin/bash

IMAGE_NAME="centos-owncloud:latest"

ctr=$(buildah from centos)

buildah run $ctr -- yum update -y
buildah run $ctr -- yum install -y epel-release
buildah run $ctr -- yum install -y nginx
buildah run $ctr -- yum install -y wget

# FIXME: should be set
#buildah run $ctr -- sed -i 's/user = apache/user = nginx' /etc/php-fpm.d/www.conf
#buildah run $ctr -- sed -i 's/group = apache/group = nginx' /etc/php-fpm.d/www.conf

buildah run $ctr -- chown -R root:nginx /var/lib/php/session/

buildah copy $ctr confs/nginx.conf /etc/nginx/
buildah copy $ctr confs/php.conf /etc/nginx/default.d/php.conf


buildah run $ctr -- wget http://download.owncloud.org/download/repositories/production/CentOS_7/ce:stable.repo -O /etc/yum.repos.d/owncloud.repo
buildah run $ctr -- yum -y install owncloud-files


# testing -- use external DB ideal
#buildah run $ctr -- yum -y install wget mariadb-server mariadb

# This needs to be done - because php-fpm is creating pid file in this location
# Why this isn't done by rpm package is mystery

buildah config --author 'Jiri Konecny' $ctr
buildah config --port 8080 $ctr
buildah config --cmd 'nginx -g "daemon off;"' $ctr

buildah commit --rm $ctr $IMAGE_NAME
