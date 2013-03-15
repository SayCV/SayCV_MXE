# This file is part of MXE.
# See index.html for further information.

PKG             := yasm
$(PKG)_IGNORE   := 
$(PKG)_CHECKSUM := 4c4d1951181a610923523cb10d83d9ae9952fbf3
$(PKG)_SUBDIR   := .
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION)-win32.exe
$(PKG)_URL      := http://www.tortall.net/projects/$(PKG)/releases/$(PKG)-$($(PKG)_VERSION)-win32.exe
$(PKG)_DEPS     := 

define $(PKG)_UPDATE
    echo $($(PKG)_VERSION)
endef

define $(PKG)_BUILD
    $(INSTALL) -d '$(PREFIX)/bin'
    cd '$(1)' && \
        cp -p $(PKG)-$($(PKG)_VERSION)-win32.exe '$(PREFIX)/bin/$(PKG).exe'
endef