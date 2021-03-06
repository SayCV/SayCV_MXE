# This file is part of MXE.
# See index.html for further information.

PKG             := binutils
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := 587fca86f6c85949576f4536a90a3c76ffc1a3e1
$(PKG)_SUBDIR   := binutils-$($(PKG)_VERSION)
$(PKG)_FILE     := binutils-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := ftp://ftp.gnu.org/pub/gnu/binutils/$($(PKG)_FILE)
$(PKG)_URL_2    := ftp://ftp.cs.tu-berlin.de/pub/gnu/binutils/$($(PKG)_FILE)
$(PKG)_DEPS     :=

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://ftp.gnu.org/gnu/binutils/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="binutils-\([0-9][^"]*\)\.tar.*,\1,p' | \
    grep -v '^2\.1' | \
    head -1
endef

define $(PKG)_BUILD
    # install config.guess for general use
    $(INSTALL) -d '$(PREFIX)/bin'
    $(INSTALL) -m755 '$(1)/config.guess' '$(PREFIX)/bin/'

    # install target-specific autotools config file
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/share'
    echo "ac_cv_build=`$(1)/config.guess`" > '$(PREFIX)/$(TARGET)/share/config.site'

    if ! test -f '$(1)/stamp_cfg_$($(PKG)_SUBDIR)'; then \
      cd '$(1)' && ./configure \
          --target='$(TARGET)' \
          --build="`config.guess`" \
          --prefix='$(PREFIX)/opt/binutils' \
          --with-gcc \
          --with-gnu-ld \
          --with-gnu-as \
          --disable-nls \
          --disable-shared \
          --disable-werror \
      && \
        cd '$(1)' && touch 'stamp_cfg_$($(PKG)_SUBDIR)'; \
    fi
    
    if ! test -f '$(1)/stamp_make_$($(PKG)_SUBDIR)'; then \
      $(MAKE) -C '$(1)' -j '$(JOBS)' \
      && \
      cd '$(1)' && touch 'stamp_make_$($(PKG)_SUBDIR)'; \
    fi
    
    if ! test -f '$(1)/stamp_install_$($(PKG)_SUBDIR)'; then \
      $(MAKE) -C '$(1)' -j 1 install \
      && \
      cd '$(1)' && touch 'stamp_install_$($(PKG)_SUBDIR)'; \
    fi
    
    if test -d '$(PREFIX)/opt/binutils'; then \
      cd '$(PREFIX)/opt/binutils' && \
      echo 'Hacked to copy origin files and add transfer_programe_name:i686-pc-mingw32- to *.exe' && \
      cp -rpv * '$(PREFIX)'; \
      cd '$(PREFIX)/opt/binutils/bin' && \
      ls | xargs -I {} mv {} '$(TARGET)-{}' && \
      cp -rpv * '$(PREFIX)/bin'; \
      cd '$(PREFIX)/opt' && \
      rm -rf '$(PREFIX)/opt/binutils'; \
    fi
endef
