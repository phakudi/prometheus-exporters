# Makefile for building linux packages for mysqld_exporter


export SRC_PACKAGE_NAME := ${PACKAGE_MODULE}
export DEB_PACKAGE_NAME := mysqld-exporter
export PACKAGE_REVISION := 1
export PACKAGE_LICENSE := Apache-2.0
export DEB_SRC_ARCHS := 386 amd64
export DEB_TARGET_amd64_ARCH := amd64
export DEB_TARGET_arm64_ARCH := arm64
export DEB_TARGET_armv7_ARCH := armhf
export DEB_TARGET_ppc64le_ARCH := ppc64el
export DEB_TARGET_mips64le_ARCH := mips64el

all: call-deb

call-deb:
	make 'DEB_SRC_ARCH=amd64' -C deb/
	make 'DEB_SRC_ARCH=arm64' -C deb/
	make 'DEB_SRC_ARCH=armv7' -C deb/
	make 'DEB_SRC_ARCH=ppc64le' -C deb/
	make 'DEB_SRC_ARCH=mips64le' -C deb/

lint:
	make 'DEB_SRC_ARCH=amd64' -C deb/ lint
	make 'DEB_SRC_ARCH=arm64' -C deb/ lint
	make 'DEB_SRC_ARCH=armv7' -C deb/ lint
	make 'DEB_SRC_ARCH=ppc64le' -C deb/ lint
	make 'DEB_SRC_ARCH=mips64le' -C deb/ lint
