# Makefile for building deb packages for mysqld_exporter

OS := linux
DEB_BINTRAY_URL := https://dl.bintray.com/apptuitai/debian/pool/m/$(DEB_PACKAGE_NAME)/
PKG_BASENAME := $(DEB_PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION)
DEB_TARGET_ARCH := $(DEB_TARGET_$(DEB_SRC_ARCH)_ARCH)
DEB := $(PKG_BASENAME)_$(DEB_TARGET_ARCH).deb
SRC_PKG_BASE_URL := https://github.com/prometheus/$(SRC_PACKAGE_NAME)/releases/download/v$(PACKAGE_VERSION)/
SRC_PKG_BASE_NAME := $(SRC_PACKAGE_NAME)-$(PACKAGE_VERSION).$(OS)-$(DEB_SRC_ARCH)
SRC_PKG_FILE_NAME := $(SRC_PKG_BASE_NAME).tar.gz
SRC_PKG_URL := $(SRC_PKG_BASE_URL)$(SRC_PKG_FILE_NAME)

all: clean check dlsrcpkg deb

clean:
	rm -fr build/
	rm -fr build-tmp/
	rm -f dist/$(DEB)

check: ;
#	curl --output /dev/null --silent --head --fail ${DEB_BINTRAY_URL} || exit 1

dlsrcpkg:
	mkdir -p build-tmp/
	cd build-tmp/ && curl -L -O $(SRC_PKG_URL) && tar -zxvf $(SRC_PKG_FILE_NAME) && cd ..

deb:
	mkdir -p dist/
	mkdir -p build/DEBIAN/
	mkdir -p build/opt/$(SRC_PACKAGE_NAME)/
	cp -r control/* build/DEBIAN/
	cp -r etc/ build/
	cp build-tmp/$(SRC_PKG_BASE_NAME)/$(SRC_PACKAGE_NAME) build/opt/$(SRC_PACKAGE_NAME)/
	set -e; { \
		sed \
			-e 's/@DEB_PACKAGE_NAME@/$(DEB_PACKAGE_NAME)/' \
			-e 's/@PACKAGE_VERSION@/$(PACKAGE_VERSION)/' \
			-e 's/@PACKAGE_REVISION@/$(PACKAGE_REVISION)/' \
			-e 's/@PACKAGE_LICENSE@/$(PACKAGE_LICENSE)/' \
			-e 's/@DEB_TARGET_ARCH@/$(DEB_TARGET_ARCH)/' \
		control/control; \
	} >build/DEBIAN/control
	cd build; find . -type f ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
	dpkg-deb -b build dist/$(DEB)

lint:
	lintian --no-tag-display-limit dist/$(DEB)
