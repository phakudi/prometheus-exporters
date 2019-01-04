#!/bin/bash

if [ -r ../common.sh ]; then
	. ../common/common.sh
else
	curl=$(which curl)
	r=$?
	if [ $r == 0 ]; then
		$curl -o /tmp/common.sh https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/common/common.sh
	else
		wget=$(which wget)
		r=$?
		if [ $r == 0 ]; then
			$wget -O /tmp/common.sh https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/common/common.sh
		else
			echo "Neither 'curl' nor 'wget' found. Please install at least one of these packages."
			exit 1
		fi
	fi
	. /tmp/common.sh
fi

PACKAGE_NAME='memcached-exporter'
OS=$(get_os)

DEFAULT_MEMCACHE_HOST='localhost'
DEFAULT_MEMCACHE_PORT='11211'

function localize_exporter_config() {
	echo -n "Memcache IP [$DEFAULT_MEMCACHE_HOST] : "
	read memcache_host
	memcache_host=${memcache_host:-${DEFAULT_MYSQL_HOST}}
	echo -n "Memcache Port [$DEFAULT_MEMCACHE_PORT] : "
	read memcache_port
	memcache_port=${memcache_port:-${DEFAULT_MEMCACHE_PORT}}
	print_message "info" "Updating exporter configuration..."
	sed -e "s/@MEMCACHE_HOST@/${memcache_host}/g" -e "s/@MEMCACHE_PORT@/${memcache_port}/g" -i /etc/default/memcached-exporter
	is_systemd=0

	if [ -d /run/systemd/system ]; then
	   is_systemd=1
	fi

	if [ $is_systemd -eq 1 ]; then
		sed -e "s/@MEMCACHE_HOST@/${memcache_host}/" -e "s/@MEMCACHE_PORT@/${memcache_port}/g" -i /usr/lib/systemd/system/mysqld-exporter.service
		systemctl daemon-reload
	fi

	print_message "info" "DONE\n"
}

trap 'post_error ${PACKAGE_NAME}' ERR
check_root
setup_log $PACKAGE_NAME
post_complete $PACKAGE_NAME

case $OS in
    RedHat)
        install_redhat $PACKAGE_NAME
        localize_exporter_config
        start_service $PACKAGE_NAME
        ;;

    Debian)
        install_debian $PACKAGE_NAME
        localize_exporter_config
        start_service $PACKAGE_NAME
        ;;

    *)
        print_message "error" "Your OS/distribution is not supported by this install script.\n"
        exit 1;
        ;;
esac
