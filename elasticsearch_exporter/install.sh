#!/bin/bash

. ../common/common.sh

PACKAGE_NAME='elasticsearch-exporter'
OS=$(get_os)

trap post_error ERR
setup_log $PACKAGE_NAME
post_complete $PACKAGE_NAME

case $OS in
    RedHat)
        install_redhat $PACKAGE_NAME
        ;;

    Debian)
        install_debian $PACKAGE_NAME
        ;;

    *)
        print_message "error" "Your OS/distribution is not supported by this install script.\n"
        exit 1;
        ;;
esac
