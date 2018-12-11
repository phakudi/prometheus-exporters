# Makefile for building linux packages for mysqld_exporter


export SRC_PACKAGE_NAME := mysqld_exporter
export DEB_PACKAGE_NAME := mysqld-exporter
export PACKAGE_VERSION := 0.11.0
export PACKAGE_REVISION := 1
export PACKAGE_LICENSE := Apache-2.0
export DEB_SRC_ARCHS := 386 amd64
export DEB_TARGET_amd64_ARCH := amd64
export DEB_TARGET_386_ARCH := i386

all: call-deb

call-deb:
	make 'DEB_SRC_ARCH=386' -C deb/
	make 'DEB_SRC_ARCH=amd64' -C deb/

lint:
	make 'DEB_SRC_ARCH=386' -C deb/ lint
	make 'DEB_SRC_ARCH=amd64' -C deb/ lint
