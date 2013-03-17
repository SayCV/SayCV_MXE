# This file is part of MXE.
# See index.html for further information.

PKG             := pkg-config
$(PKG)_IGNORE   := 
$(PKG)_CHECKSUM := 08249417a51c0a7a940e4276105b142b77e576b5
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://pkgconfig.freedesktop.org/releases/$($(PKG)_FILE)
$(PKG)_DEPS     := mingwrt w32api binutils gtk-bin
 
PKG_SRC_BUILD   := 1
$(PKG)_DIR_SRC  := $(PKG_DIR)/$(PKG)
$(PKG)_GIT_URL  := git://anongit.freedesktop.org/pkg-config
$(PKG)_SRC_TYPE := git
#$(PKG)_SRC_TYPE := tar

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://pkgconfig.freedesktop.org/releases/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="pkg-config-\([0-9.]*\).tar.gz".*,\1,p' | \
    head -1
endef

define $(PKG)_SRC_GET
    if test '$($(PKG)_SRC_TYPE)' == 'git'; then \
      echo "git clone src ...";  \
      cd $(PKG_DIR) && \
      git clone $($(PKG)_GIT_URL) $(PKG); \
    fi
endef
  
define $(PKG)_BUILD_CFG
	mkdir -p '$(1).build'; \
  $(SED) -i 's,aclocal,aclocal -I $(PREFIX)/$(TARGET)/share/aclocal,' '$($(PKG)_DIR_SRC)/autogen.sh'; \
  $(SED) -i 's,libtoolize,$(LIBTOOLIZE),'                             '$($(PKG)_DIR_SRC)/autogen.sh'; \
  cd    '$(1).build' && $(SHELL) '$($(PKG)_DIR_SRC)/./autogen.sh' \
        --cache-file=win32.cache \
        --build="`config.guess`" \
        --prefix='$(PREFIX)' \
        --with-gcc \
        --with-gnu-ld \
        --with-gnu-as \
        --disable-nls \
        --disable-shared \
        --disable-werror \
        --with-internal-glib \
         &&  \
  cd '$(1).build' && touch 'stamp_cfg_$($(PKG)_SUBDIR)'
endef

define $(PKG)_BUILD
	if test '$(PKG_SRC_BUILD)' = '1'; then \
  	if ! test -d '$($(PKG)_DIR_SRC)'; then \
  		$(call $(PKG)_SRC_GET,$(1),$(2)); \
  	fi; \
    \
  	if ! test -f '$($(PKG)_DIR_SRC)/autogen.sh'; then \
  		  cd '$($(PKG)_DIR_SRC)' && autoreconf -iv; \
  	fi; \
  	  \
  	rm -f '$(1).build/win32.cache'; \
  	if ! test -f '$(1).build/win32.cache'; then \
      echo create win32.cache and prevent configure from changing it; \
    	mkdir -p '$(1).build'; \
    	cd '$(1).build' && touch win32.cache \
    	&& echo -e "glib_cv_long_long_format=I64" >> win32.cache \
    	&& echo -e "glib_cv_stack_grows=no" >> win32.cache \
    	&& chmod a-w win32.cache; \
    fi; \
    \
    if ! test -f '$(1).build/stamp_cfg_$($(PKG)_SUBDIR)'; then \
      $(call $(PKG)_BUILD_CFG,$(1),$(2)); \
    fi; \
    \
    if ! test -f '$(1).build/stamp_make_$($(PKG)_SUBDIR)'; then \
      $(MAKE) -C '$(1).build' -j '$(JOBS)' \
      && \
      cd '$(1).build' && touch 'stamp_make_$($(PKG)_SUBDIR)'; \
    fi; \
    \
    if ! test -f '$(1).build/stamp_install_$($(PKG)_SUBDIR)'; then \
      $(MAKE) -C '$(1).build' -j 1 install \
      && \
      cd '$(1).build' && touch 'stamp_install_$($(PKG)_SUBDIR)'; \
    fi; \
	fi
	
  if test '$(PKG_SRC_BUILD)' = '0'; then \
    echo "Build Bin: pkg-config Depend On Install Package gtk-bin."; \
  fi
endef