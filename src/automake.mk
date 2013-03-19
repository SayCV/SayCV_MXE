# This file is part of MXE.
# See index.html for further information.

PKG             := automake
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := 735e5a755dd4ba24dbb345901198873b2686804d
$(PKG)_SUBDIR   := automake-$($(PKG)_VERSION)
$(PKG)_FILE     := automake-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := $(PKG_GNU)/automake/$($(PKG)_FILE)
$(PKG)_DEPS     := autoconf

define $(PKG)_UPDATE
    $(WGET) -O- 'http://ftp.gnu.org/gnu/automake' | \
    $(SED) -n 's,.*automake-\([0-9][^<]*\).*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
	if ! test -f '$(1).build/stamp_cfg_$($(PKG)_SUBDIR)'; then \
    mkdir -p '$(1).build'; \
    cd    '$(1).build' && '$(1)/configure' \
        --host='$(TARGET)' \
        --disable-shared \
        --prefix='$(PREFIX)' &&  \
		cd '$(1).build' && touch 'stamp_cfg_$($(PKG)_SUBDIR)'; \
    fi
    $(MAKE) -C '$(1).build' -j '$(JOBS)' all     bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    $(MAKE) -C '$(1).build' -j '$(JOBS)' info    bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    $(MAKE) -C '$(1).build' -j 1         install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
endef
