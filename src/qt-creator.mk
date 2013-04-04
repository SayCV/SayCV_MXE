# This file is part of MXE.
# See index.html for further information.

PKG             := qt-creator
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := b9d5b99034e8e799b500e800b6dc032eb85f501b
$(PKG)_SUBDIR   := .
$(PKG)_FILE     := $(PKG)-windows-opensource-$($(PKG)_VERSION).exe
$(PKG)_URL      := http://releases.qt-project.org/qtcreator/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := 

define $(PKG)_UPDATE
    echo $(qt-creator_VERSION)
endef

define $(PKG)_BUILD
      cd '$(1)' && \
      	7z.exe x $(qt-creator_FILE) -oqt-creator
      $(INSTALL) -d '$(PREFIX)/opt/qt-creator'
      cd '$(1)' && \
        cp -rpv * '$(PREFIX)/opt/qt-creator'
endef
