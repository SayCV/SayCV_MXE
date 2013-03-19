# This file is part of MXE.
# See index.html for further information.

PKG             := autoconf
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := 562471cbcb0dd0fa42a76665acf0dbb68479b78a
$(PKG)_SUBDIR   := autoconf-$($(PKG)_VERSION)
$(PKG)_FILE     := autoconf-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := $(PKG_GNU)/autoconf/$($(PKG)_FILE)
$(PKG)_DEPS     := m4

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://ftp.gnu.org/gnu/autoconf' | \
    $(SED) -n 's,.*autoconf-\([0-9][^<]*\).*,\1,p' | \
    head -1
endef

# http://iweb.dl.sourceforge.net/project/msysdev/autotool/m4/m4-1.4.16/m4-1.4.16-1-msys-1.0.17-bin.tar.lzma
define $(PKG)_BUILD
	if ! test -f '$(1).build/stamp_cfg_$($(PKG)_SUBDIR)'; then \
	cd    '$(1)' && autoreconf -fvi; \
    mkdir -p '$(1).build'; \
    cd    '$(1).build' && '../$($(PKG)_SUBDIR)/configure' \
        --host='$(TARGET)' \
        --disable-shared \
        --prefix='$(PREFIX)' \
         &&  \
		cd '$(1).build' && touch 'stamp_cfg_$($(PKG)_SUBDIR)'; \
    fi
    $(MAKE) -C '$(1).build' -j '$(JOBS)' all
    $(MAKE) -C '$(1).build' -j '$(JOBS)' info
    $(MAKE) -C '$(1).build' -j 1         install
endef