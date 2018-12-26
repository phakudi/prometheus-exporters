#!/bin/bash

. ../common.sh

PACKAGE_NAME='mysqld-exporter'
OS=$(get_os)

DEFAULT_MYSQL_HOST='localhost'
DEFAULT_MYSQL_PORT='3306'
DEFAULT_MYSQL_USER='root'

trap 'post_error ${PACKAGE_NAME}' ERR
check_root
setup_log $PACKAGE_NAME
post_complete $PACKAGE_NAME

case $OS in
    RedHat)
        install_redhat $PACKAGE_NAME
        echo -n "MySQL IP [localhost] : "
        read mysql_host
        mysql_host=${mysql_host:-${DEFAULT_MYSQL_HOST}}
        echo -n "MySQL Port [3306] : "
        read mysql_port
        mysql_port=${mysql_port:-${DEFAULT_MYSQL_PORT}}
        echo -n "MySQL User [root] : "
        read mysql_user
        mysql_user=${mysql_user:-${DEFAULT_MYSQL_USER}}
        echo -n "MySQL Password [] : "
        read -s mysql_password
        sed -e "s/@MYSQL_HOST@/$mysql_host/" -e "s/@MYSQL_PORT@/${mysql_port}/" -e "s/@MYSQL_USER@/${mysql_user}/" -e "s/@MYSQL_PASSWORD@/${mysql_password}/" -i /etc/default/mysqld_exporter

        service mysqld-exporter start
        ;;

    Debian)
        install_debian $PACKAGE_NAME
        echo -n "MySQL IP [localhost] : "
        read mysql_host
        mysql_host=${mysql_host:-${DEFAULT_MYSQL_HOST}}
        echo -n "MySQL Port [3306] : "
        read mysql_port
        mysql_port=${mysql_port:-${DEFAULT_MYSQL_PORT}}
        echo -n "MySQL User [root] : "
        read mysql_user
        mysql_user=${mysql_user:-${DEFAULT_MYSQL_USER}}
        echo -n "MySQL Password [] : "
        read -s mysql_password
        sed -e "s/@MYSQL_HOST@/$mysql_host/" -e "s/@MYSQL_PORT@/${mysql_port}/" -e "s/@MYSQL_USER@/${mysql_user}/" -e "s/@MYSQL_PASSWORD@/${mysql_password}/" -i /etc/default/mysqld_exporter
        service mysqld-exporter start
        ;;

    *)
        print_message "error" "Your OS/distribution is not supported by this install script.\n"
        exit 1;
        ;;
esac
