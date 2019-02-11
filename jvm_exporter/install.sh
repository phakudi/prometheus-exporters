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

PACKAGE_NAME='jvm-exporter'
OS=$(get_os)

DEFAULT_JVM_HOST='localhost'
DEFAULT_JVM_PORT='7199'
DEFAULT_JVM_JMX_URL='service:jmx:rmi:///jndi/rmi://localhost:7199/jmxrmi'
DEFAULT_JVM_ALIAS=$(hostname -s)
DEFAULT_JVM_PASSWORD=""

function configure_exporter() {
	if [ -z "$1" ] || [ ! "$1" == "--interactive" ]
	then
		configure_exporter_noninteractively
	else
		configure_exporter_interactively
	fi
}

function configure_exporter_noninteractively() {
	print_message "info" "Command line option --interactive not found. Proceeding in non-interactive mode.\n"
	if [ -z "$JVM_JMX_URL" ];
	then
		JVM_JMX_URL=${DEFAULT_JVM_JMX_URL}
		print_message "warn" "Env variable JVM_JMX_URL not found. Using Default (${JVM_JMX_URL}) for accessing JVM JMX Metrics. Please edit /etc/default/jvm-exporter if you would like to change it later.\n"
	fi
	if [ -z "$JVM_ALIAS" ];
	then
		JVM_ALIAS=${DEFAULT_JVM_ALIAS}
		print_message "warn" "Env variable JVM_ALIAS not found. Using Default (${JVM_ALIAS}) for JVM Metrics. Please edit /etc/default/jvm-exporter if you would like to change it later.\n"
	fi
	print_message "info" "Using JVM_JMX_URL=$JVM_JMX_URL JVM_ALIAS=$JVM_ALIAS to configure exporter.\n"
	update_exporter_configuration $JVM_JMX_URL $JVM_ALIAS
}

function configure_exporter_interactively() {
	print_message "info" "Interactive Configuration for JVM Exporter\n"
	read -p "JVM IP/Host [$DEFAULT_JVM_HOST] : " jvm_host
	jvm_host=${jvm_host:-${DEFAULT_JVM_HOST}}
	read -p "JVM JMX Port [$DEFAULT_JVM_PORT] : " jvm_port
	jvm_port=${jvm_port:-${DEFAULT_JVM_PORT}}
	read -p "JVM alias for metrics [$jvm_host] : " jvm_alias
	jvm_alias=${jvm_alias:-${jvm_host}}
	jvm_jmx_url="service:jmx:rmi:///jndi/rmi://$jvm_host:$jvm_port/jmxrmi"
	update_exporter_configuration $jvm_jmx_url $jvm_alias
}

function update_exporter_configuration() {
	print_message "info" "Updating exporter configuration..."
	sed \
		-e "s|jmxUrl: ${DEFAULT_JVM_JMX_URL}|jmxUrl: ${1}|g" \
		-e "s|      \"alias\": \"localhost\"|      \"alias\": \"${2}\"|g" \
		-i /opt/prometheus/jvm_exporter/conf/jvm.yml
	print_message "info" "DONE\n"
}

trap 'post_error ${PACKAGE_NAME}' ERR
check_root
setup_log $PACKAGE_NAME
post_complete $PACKAGE_NAME

case $OS in
    RedHat)
        install_redhat $PACKAGE_NAME
        configure_exporter $0
        start_service $PACKAGE_NAME
        ;;

    Debian)
        install_debian $PACKAGE_NAME
        configure_exporter $0
        start_service $PACKAGE_NAME
        ;;

    *)
        print_message "error" "Your OS/distribution is not supported by this install script.\n"
        exit 1;
        ;;
esac
