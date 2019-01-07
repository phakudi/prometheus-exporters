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

PACKAGE_NAME='elasticsearch-exporter'
OS=$(get_os)

DEFAULT_ELASTICSEARCH_URL='http://elasticsearch:9200'

function localize_exporter_config() {
	echo -n "Elasticsearch URL [$DEFAULT_ELASTICSEARCH_URL] : "
	read es_url
	es_url=${es_url:-${$DEFAULT_ELASTICSEARCH_URL}}
	print_message "info" "Updating exporter configuration..."
	sed -e "s/@ELASTICSEARCH_URL@/${es_url}/g" -i /etc/default/elasticsearch-exporter
	is_systemd=0

	if [ -d /run/systemd/system ]; then
	   is_systemd=1
	fi

	if [ $is_systemd -eq 1 ]; then
		sed -e "s/@ELASTICSEARCH_URL@/${es_url}/" -i /usr/lib/systemd/system/elasticsearch-exporter.service
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
