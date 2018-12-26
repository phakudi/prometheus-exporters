#!/bin/bash

. ../common.sh

PACKAGE_NAME='mysqld-exporter'
OS=$(get_os)

DEFAULT_MYSQL_HOST='localhost'
DEFAULT_MYSQL_PORT='3306'
DEFAULT_MYSQL_USER='apptuit'

function localize_exporter_config() {
	print_message "info" "The install script will now setup a new user (apptuit) on your MySQL instance for metrics collection"
	echo -n "MySQL IP [localhost] : "
	read mysql_host
	mysql_host=${mysql_host:-${DEFAULT_MYSQL_HOST}}
	echo -n "MySQL Port [3306] : "
	read mysql_port
	mysql_port=${mysql_port:-${DEFAULT_MYSQL_PORT}}
	echo -n "Password for MySQL 'root' User : "
	read -s mysql_root_password
	echo -n "User for metrics collection [apptuit] : "
	read mysql_user
	mysql_user=${mysql_user:-${DEFAULT_MYSQL_USER}}
	echo -n "Setup password for '${mysql_user}' User : "
	read -s mysql_user_password
	echo -n "Creating MySQL user '${mysql_user}' and granting needed permissions..."
	mysql -u root -p${mysql_root_password} mysql -e "CREATE USER '${mysql_user}'@'localhost' IDENTIFIED BY '${mysql_user_password}';"
	mysql -u root -p${mysql_root_password} mysql -e "GRANT PROCESS ON *.* TO '${mysql_user}'@'localhost';"
	mysql -u root -p${mysql_root_password} mysql -e "GRANT SELECT ON performance_schema.* TO '${mysql_user}'@'localhost';"
	mysql -u root -p${mysql_root_password} mysql -e "GRANT REPLICATION CLIENT ON *.* to '${mysql_user}'@'localhost';"
	print_message "success" "Done"
	sed -e "s/@MYSQL_HOST@/${mysql_host}/" -e "s/@MYSQL_PORT@/${mysql_port}/" -e "s/@MYSQL_USER@/${mysql_user}/" -e "s/@MYSQL_PASSWORD@/${mysql_user_password}/" -i /etc/default/mysqld-exporter
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
