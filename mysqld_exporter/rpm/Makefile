# Makefile for building rpm packages for mysqld_exporter

OS := linux
RPM_BINTRAY_URL := https://dl.bintray.com/apptuitai/rpm/pool/m/$(RPM_PACKAGE_NAME)/
PKG_BASENAME := $(RPM_PACKAGE_NAME)-$(PACKAGE_VERSION)-$(PACKAGE_REVISION)
RPM_TARGET_ARCH := $(RPM_TARGET_$(RPM_SRC_ARCH)_ARCH)
RPM := $(PKG_BASENAME).$(RPM_TARGET_ARCH).rpm
SRC_PKG_BASE_URL := https://github.com/prometheus/$(SRC_PACKAGE_NAME)/releases/download/v$(PACKAGE_VERSION)/
SRC_PKG_BASE_NAME := $(SRC_PACKAGE_NAME)-$(PACKAGE_VERSION).$(OS)-$(RPM_SRC_ARCH)
SRC_PKG_FILE_NAME := $(SRC_PKG_BASE_NAME).tar.gz
SRC_PKG_URL := $(SRC_PKG_BASE_URL)$(SRC_PKG_FILE_NAME)

all: clean check dlsrcpkg rpm

clean:
	rm -fr build/
	rm -fr build-tmp/
	rm -f dist/$(RPM)

check: ;
#	curl --output /dev/null --silent --head --fail ${RPM_BINTRAY_URL} || exit 1

dlsrcpkg:
	mkdir -p build-tmp/
	cd build-tmp/ && curl -L -O $(SRC_PKG_URL) && tar -zxvf $(SRC_PKG_FILE_NAME) && cd ..

rpm:
	mkdir -p dist/
	mkdir -p build/
	set -e; { \
		sed \
			-e 's/@GIT_VERSION@/$(GIT_VERSION)/' \
			-e 's/@GIT_FULLSHA1@/$(GIT_FULLSHA1)/' \
			-e 's/@GIT_SHORTSHA1@/$(GIT_SHORTSHA1)/' \
			-e 's/@SRC_PKG_BASE_NAME@/$(SRC_PKG_BASE_NAME)/' \
			-e 's/@RPM_PACKAGE_NAME@/$(RPM_PACKAGE_NAME)/' \
			-e 's/@PACKAGE_VERSION@/$(PACKAGE_VERSION)/' \
			-e 's/@PACKAGE_REVISION@/$(PACKAGE_REVISION)/' \
			-e 's/@PACKAGE_LICENSE@/$(PACKAGE_LICENSE)/' \
			-e 's/@RPM_TARGET_ARCH@/$(RPM_TARGET_ARCH)/' \
		spec/${RPM_PACKAGE_NAME}-${INIT_SYSTEM}.spec; \
	} >build/${RPM_PACKAGE_NAME}-${INIT_SYSTEM}-t.spec
	rpmbuild --define "_topdir %(pwd)/build" --target ${RPM_TARGET_ARCH} -bb build/$(RPM_PACKAGE_NAME)-${INIT_SYSTEM}-t.spec
	mv build/RPMS/${RPM_TARGET_ARCH}/${RPM} dist/

lint:
	lintian --no-tag-display-limit dist/$(RPM)
