# Makefile for building deb packages for jvm_exporter

OS := linux
DEB_BINTRAY_URL := https://dl.bintray.com/apptuitai/debian/pool/j/$(DEB_PACKAGE_NAME)/
PACKAGE_BASE_NAME := $(DEB_PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION)
DEB_TARGET_ARCH := $(DEB_TARGET_$(DEB_SRC_ARCH)_ARCH)
DEB := $(PACKAGE_BASE_NAME)_$(DEB_TARGET_ARCH).deb
SRC_PKG_BASE_URL := https://github.com/oliver006/$(SRC_PACKAGE_NAME)/releases/download/v$(PACKAGE_VERSION)/
SRC_PKG_BASE_NAME := $(SRC_PACKAGE_NAME)-v$(PACKAGE_VERSION).$(OS)-$(DEB_SRC_ARCH)
SRC_PKG_FILE_NAME := $(SRC_PKG_BASE_NAME).tar.gz
SRC_PKG_URL := $(SRC_PKG_BASE_URL)$(SRC_PKG_FILE_NAME)

all: clean deb

clean:
	rm -fr build/
	rm -f dist/$(DEB)

deb: clean mkdeb

mkdeb:
	mkdir -p dist/
	mkdir -p build/DEBIAN/
	cp -r ../assets/* build/
	cp -r ../../common/assets/* build/
	cp -r ../../jmx_exporter_base/assets/* build/
	mv build/usr/lib/systemd/system/template-exporter.service build/usr/lib/systemd/system/$(PACKAGE_NAME).service
	mkdir -p build/etc/init.d/
	mkdir -p build/opt/prometheus/$(SRC_PACKAGE_NAME)/bin/
	cp ../../common/deb/control/* build/DEBIAN/
	cp ../../common/deb/assets/etc/init.d/template-exporter build/etc/init.d/$(PACKAGE_NAME)
	sed -i \
			-e 's/@GIT_VERSION@/$(GIT_VERSION)/g' \
			-e 's/@GIT_FULLSHA1@/$(GIT_FULLSHA1)/g' \
			-e 's/@GIT_SHORTSHA1@/$(GIT_SHORTSHA1)/g' \
			-e 's/@SRC_PKG_BASE_NAME@/$(SRC_PKG_BASE_NAME)/g' \
			-e 's/@SRC_PACKAGE_NAME@/$(SRC_PACKAGE_NAME)/g' \
			-e 's/@DEB_PACKAGE_NAME@/$(DEB_PACKAGE_NAME)/g' \
			-e 's/@DEB_TARGET_ARCH@/$(DEB_TARGET_ARCH)/g' \
			-e 's/@DEB_PACKAGE_START_DEPS@/$$network/g' \
			-e 's/@DEB_PACKAGE_STOP_DEPS@/$$network/g' \
			-e 's/@PACKAGE_NAME@/$(PACKAGE_NAME)/g' \
			-e 's/@PACKAGE_DESCRIPTION@/$(PACKAGE_DESCRIPTION)/g' \
			-e 's/@PACKAGE_VERSION@/$(PACKAGE_VERSION)/g' \
			-e 's/@PACKAGE_REVISION@/$(PACKAGE_REVISION)/g' \
			-e 's/@PACKAGE_LICENSE@/$(PACKAGE_LICENSE)/g' \
		-e 's/@PACKAGE_SYSTEMD_SERVICE_DEPS@//g' \
		-e 's/@EXPORTER_ENVIRONMENT_VARIABLES@//g' \
		build/DEBIAN/control build/DEBIAN/conffiles build/DEBIAN/postinst build/DEBIAN/prerm build/etc/init.d/$(PACKAGE_NAME) build/usr/lib/systemd/system/$(PACKAGE_NAME).service; \
	chmod 775 build/DEBIAN/postinst
	chmod 775 build/DEBIAN/prerm
	cd build; find . -type f ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
	dpkg-deb -b build dist/$(DEB)

lint:
	lintian --no-tag-display-limit dist/$(DEB)
