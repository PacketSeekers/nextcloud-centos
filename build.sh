#!/bin/bash

IMAGE_NAME="centos-owncloud:latest"

ctr=$(buildah from centos)
buildah run $ctr -- yum install -y centos-release-scl epel-release
buildah run $ctr -- yum install -y nginx rh-php70 rh-php70-php rh-php70-php-gd rh-php70-php-mbstring rh-php70-php-mysqlnd
buildah run $ctr -- yum install -y php php-mysql php-pecl-zip php-xml php-mbstring php-gd php-fpm php-intl
buildah run $ctr -- yum install -y wget

# FIXME: should be set
#buildah run $ctr -- sed -i 's/user = apache/user = nginx' /etc/php-fpm.d/www.conf
#buildah run $ctr -- sed -i 's/group = apache/group = nginx' /etc/php-fpm.d/www.conf

buildah run $ctr -- chown -R root:nginx /var/lib/php/session/

buildah copy $ctr confs/nginx.conf /etc/nginx/
buildah copy $ctr confs/php.conf /etc/nginx/default.d/php.conf


buildah run $ctr -- wget http://download.owncloud.org/download/repositories/production/CentOS_7/ce:stable.repo -O /etc/yum.repos.d/owncloud.repo
buildah run $ctr -- yum -y install owncloud-files


# FIXME: probably not required in container
#buildah run $ctr -- semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/owncloud/data'
#buildah run $ctr -- restorecon '/var/www/html/owncloud/data'
#buildah run $ctr -- semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/owncloud/config'
#buildah run $ctr -- restorecon '/var/www/html/owncloud/config'
#buildah run $ctr -- semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/owncloud/apps'
#buildah run $ctr -- restorecon '/var/www/html/owncloud/apps'
#
#buildah run $ctr -- firewall-cmd --permanent --add-service=http
#buildah run $ctr -- firewall-cmd --permanent --add-service=https
#buildah run $ctr -- firewall-cmd --reload

# testing -- use external DB ideal
#buildah run $ctr -- yum -y install wget mariadb-server mariadb

buildah run $ctr -- systemctl enable nginx php-fpm
buildah run $ctr -- systemctl restart php-fpm

buildah config --author 'Jiri Konecny' $ctr
buildah config --port 8080 $ctr
buildah config --cmd 'nginx -g "daemon off;"' $ctr

#buildah commit --rm $ctr $IMAGE_NAME
