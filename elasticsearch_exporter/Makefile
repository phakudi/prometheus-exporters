# Makefile for building linux packages for elasticsearch_exporter


export SRC_PACKAGE_NAME := ${PACKAGE_MODULE}
export DEB_PACKAGE_NAME := elasticsearch-exporter
export PACKAGE_REVISION := 1
export PACKAGE_LICENSE := Apache-2.0
export DEB_TARGET_amd64_ARCH := amd64
export DEB_TARGET_386_ARCH := i386

all: call-deb

call-deb:
	make 'DEB_SRC_ARCH=386' -C deb/
	make 'DEB_SRC_ARCH=amd64' -C deb/

lint:
	make 'DEB_SRC_ARCH=386' -C deb/ lint
	make 'DEB_SRC_ARCH=amd64' -C deb/ lint
