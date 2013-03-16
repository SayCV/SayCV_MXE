# This file is part of MXE.
# See index.html for further information.

PKG             := gtk-bin
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := 895072c22f5bfd4ac9054d48d62d6c8b2a487098
$(PKG)_SUBDIR   := .
$(PKG)_FILE     := gtk+-bundle_$($(PKG)_VERSION)-20120208_win32.zip
$(PKG)_URL      := http://ftp.gnome.org/pub/gnome/binaries/win32/gtk+/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     := unzip

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://ftp.gnome.org/pub/gnome/binaries/win32/gtk+' | \
    grep '<a href=' | \
    $(SED) -n 's,.*<a[^>]*>\([0-9]*\.[0-9]*[02468]\.[^<]*\)<.*,\1,p' | \
    grep -v '^2\.9' | \
    grep '^2\.' | \
    head -1
endef

define $(PKG)_BUILD
    $(INSTALL) -d '$(PREFIX)/$(TARGET)'
    cd '$(1)' && \
        cp -rpv * '$(PREFIX)'
endef
