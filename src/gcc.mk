# This file is part of MXE.
# See index.html for further information.

PKG             := gcc
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := a464ba0f26eef24c29bcd1e7489421117fb9ee35
$(PKG)_SUBDIR   := gcc-$($(PKG)_VERSION)
$(PKG)_FILE     := gcc-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := ftp://ftp.gnu.org/pub/gnu/gcc/gcc-$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_URL_2    := ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := mingwrt w32api binutils gcc-gmp gcc-mpc gcc-mpfr

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://ftp.gnu.org/gnu/gcc/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="gcc-\([0-9][^"]*\)/".*,\1,p' | \
    grep -v '^4\.[543]\.' | \
    head -1
endef

define $(PKG)_BUILD
    # unpack support libraries
    if ! test -f '$(1)/stamp_unapck_sub_libs'; then \
      cd '$(1)' && $(call UNPACK_PKG_ARCHIVE,gcc-gmp); \
      mv '$(1)/$(gcc-gmp_SUBDIR)' '$(1)/gmp'; \
      cd '$(1)' && $(call UNPACK_PKG_ARCHIVE,gcc-mpc); \
      mv '$(1)/$(gcc-mpc_SUBDIR)' '$(1)/mpc'; \
      cd '$(1)' && $(call UNPACK_PKG_ARCHIVE,gcc-mpfr); \
      mv '$(1)/$(gcc-mpfr_SUBDIR)' '$(1)/mpfr'; \
      cd '$(1)' && touch '$(1)/stamp_unapck_sub_libs'; \
    fi

    # build GCC and support libraries
    mkdir -p '$(1).build'
    if ! test -f '$(1).build/stamp_cfg_$($(PKG)_SUBDIR)'; then \
      cd    '$(1).build' && '../$(gcc_SUBDIR)/configure' \
          --target='$(TARGET)' \
          --build="`config.guess`" \
          --prefix='$(PREFIX)' \
          --libdir='$(PREFIX)/lib' \
          --enable-languages='c,c++,objc,fortran' \
          --enable-version-specific-runtime-libs \
          --with-gcc \
          --with-gnu-ld \
          --with-gnu-as \
          --disable-nls \
          --disable-shared \
          --disable-sjlj-exceptions \
          --without-x \
          --disable-win32-registry \
          --enable-threads=win32 \
          --disable-libgomp \
          --disable-libmudflap \
          --with-mpfr-include='$(1)/mpfr/src' \
          --with-mpfr-lib='$(1).build/mpfr/src/.libs' \
          $(shell [ `uname -s` == Darwin ] && echo "LDFLAGS='-Wl,-no_pie'") \
      && \
      cd '$(1).build' && touch 'stamp_cfg_$($(PKG)_SUBDIR)'; \
    fi
    
    if ! test -f '$(1).build/stamp_make_$($(PKG)_SUBDIR)'; then \
      $(MAKE) -C '$(1).build' -j '$(JOBS)' \
      && \
      cd '$(1).build' && touch 'stamp_make_$($(PKG)_SUBDIR)'; \
    fi
    
    if ! test -f '$(1).build/stamp_install_$($(PKG)_SUBDIR)'; then \
      $(MAKE) -C '$(1).build' -j 1 install \
      && \
      cd '$(1).build' && touch 'stamp_install_$($(PKG)_SUBDIR)'; \
    fi

    # create pkg-config script
    (echo '#!/bin/sh'; \
     echo 'PKG_CONFIG_PATH="$$PKG_CONFIG_PATH_$(subst -,_,$(TARGET))" PKG_CONFIG_LIBDIR='\''$(PREFIX)/$(TARGET)/lib/pkgconfig'\'' exec pkg-config --static "$$@"') \
             > '$(PREFIX)/bin/$(TARGET)-pkg-config'
    chmod 0755 '$(PREFIX)/bin/$(TARGET)-pkg-config'

    # create the CMake toolchain file
    [ -d '$(dir $(CMAKE_TOOLCHAIN_FILE))' ] || mkdir -p '$(dir $(CMAKE_TOOLCHAIN_FILE))'
    (echo 'set(CMAKE_SYSTEM_NAME Windows)'; \
     echo 'set(MSYS 1)'; \
     echo 'set(BUILD_SHARED_LIBS OFF)'; \
     echo 'set(CMAKE_BUILD_TYPE Release)'; \
     echo 'set(CMAKE_FIND_ROOT_PATH $(PREFIX)/$(TARGET))'; \
     echo 'set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)'; \
     echo 'set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)'; \
     echo 'set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)'; \
     echo 'set(CMAKE_C_COMPILER $(PREFIX)/bin/$(TARGET)-gcc)'; \
     echo 'set(CMAKE_CXX_COMPILER $(PREFIX)/bin/$(TARGET)-g++)'; \
     echo 'set(CMAKE_Fortran_COMPILER $(PREFIX)/bin/$(TARGET)-gfortran)'; \
     echo 'set(CMAKE_RC_COMPILER $(PREFIX)/bin/$(TARGET)-windres)'; \
     echo 'set(PKG_CONFIG_EXECUTABLE $(PREFIX)/bin/$(TARGET)-pkg-config)'; \
     echo 'set(QT_QMAKE_EXECUTABLE $(PREFIX)/bin/$(TARGET)-qmake)'; \
     echo 'set(CMAKE_INSTALL_PREFIX $(PREFIX)/$(TARGET) CACHE PATH "Installation Prefix")'; \
     echo 'set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug|Release|RelWithDebInfo|MinSizeRel")') \
     > '$(CMAKE_TOOLCHAIN_FILE)'
endef

# real	416m49.603s
# user	33m15.521s
# sys 	60m9.100s