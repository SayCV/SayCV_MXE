# This file is part of MXE.
# See index.html for further information.

PKG             := cmake
$(PKG)_IGNORE   := 
$(PKG)_CHECKSUM := e97a62be78390e4826297ba29ff89ef11ed0df15
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)-win32-x86
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION)-win32-x86.zip
$(PKG)_URL      := http://www.cmake.org/files/v2.8/$($(PKG)_FILE)
$(PKG)_DEPS     := unzip

define $(PKG)_UPDATE
    echo $($(PKG)_VERSION)
endef

define $(PKG)_BUILD
    $(INSTALL) -d '$(PREFIX)/opt/cmake'
    cd '$(1)' && \
        cp -rpv 'bin' 'doc' 'man' 'share' '$(PREFIX)/opt/cmake'
endef