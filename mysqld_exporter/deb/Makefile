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

deb: clean mkdeb

mkdeb:
	mkdir -p dist/
	mkdir -p build/DEBIAN/
	cp -r ../assets/* build/
	mkdir -p build/etc/init.d/
	mkdir -p build/opt/prometheus/$(SRC_PACKAGE_NAME)/bin/
	cp build-tmp/$(SRC_PKG_BASE_NAME)/$(SRC_PACKAGE_NAME) build/opt/prometheus/$(SRC_PACKAGE_NAME)/bin/
	cp ../../common/deb/control/* build/DEBIAN/
	cp ../../common/deb/assets/etc/init.d/template-exporter build/etc/init.d/mysqld-exporter
	set -e; {
		sed -i \
			-e 's/@GIT_VERSION@/$(GIT_VERSION)/g' \
			-e 's/@GIT_FULLSHA1@/$(GIT_FULLSHA1)/g' \
			-e 's/@GIT_SHORTSHA1@/$(GIT_SHORTSHA1)/g' \
			-e 's/@SRC_PKG_BASE_NAME@/$(SRC_PKG_BASE_NAME)/g' \
			-e 's/@SRC_PACKAGE_NAME@/$(SRC_PACKAGE_NAME)/g' \
			-e 's/@DEB_PACKAGE_NAME@/$(DEB_PACKAGE_NAME)/g' \
			-e 's/@DEB_PACKAGE_START_DEPS@/$$network/g' \
			-e 's/@DEB_PACKAGE_STOP_DEPS@/$$network/g' \
			-e 's/@PACKAGE_NAME@/$(PACKAGE_NAME)/g' \
			-e 's/@PACKAGE_DESCRIPTION@/$(PACKAGE_DESCRIPTION)/g' \
			-e 's/@PACKAGE_VERSION@/$(PACKAGE_VERSION)/g' \
			-e 's/@PACKAGE_REVISION@/$(PACKAGE_REVISION)/g' \
			-e 's/@PACKAGE_LICENSE@/$(PACKAGE_LICENSE)/g' \
			-e 's/@DEB_TARGET_ARCH@/$(DEB_TARGET_ARCH)/g' \
		build/DEBIAN/control build/DEBIAN/conffiles build/DEBIAN/postinst build/DEBIAN/prerm build/etc/init.d/mysqld-exporter; \
	} > /dev/null
	chmod 775 build/DEBIAN/postinst
	chmod 775 build/DEBIAN/prerm
	cd build; find . -type f ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
	dpkg-deb -b build dist/$(DEB)

lint:
	lintian --no-tag-display-limit dist/$(DEB)
