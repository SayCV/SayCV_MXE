# This file is part of MXE.
# See index.html for further information.

PKG             := pkg-config
$(PKG)_IGNORE   := 
$(PKG)_CHECKSUM := 08249417a51c0a7a940e4276105b142b77e576b5
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://pkgconfig.freedesktop.org/releases/$($(PKG)_FILE)
$(PKG)_DEPS     := mingwrt w32api binutils gtk-bin
 
$(PKG)_BUILD_SRC   := 1
$(PKG)_DIR_SRC  := $(PKG_DIR)/$(PKG)
$(PKG)_GIT_URL_GIT   := $(GIT_GNU_GIT)/$(PKG)
$(PKG)_GIT_URL_HTTP  := $(GIT_GNU_HTTP)/$(PKG).git
$(PKG)_SRC_TYPE := git

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://pkgconfig.freedesktop.org/releases/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="pkg-config-\([0-9.]*\).tar.gz".*,\1,p' | \
    head -1
endef

define $(PKG)_SRC_GET
    if test '$($(PKG)_SRC_TYPE)' == 'git'; then \
      echo "git clone src ...";  \
      cd $(PKG_DIR) && \
      git clone $($(PKG)_GIT_URL_HTTP) $(PKG); \
    fi
endef

define $(PKG)_BUILD
	if test '$($(PKG)_BUILD_SRC)' = '1'; then \
    echo 'SayCV_MXE:$(PKG):Build from DEVEL src.'; \
    echo 'SayCV_MXE:$(PKG):Get DEVEL src.'; \
    if ! test -d '$($(PKG)_DIR_SRC)'; then \
        $(call $(PKG)_SRC_GET,$(1),$(2)); \
    fi; \
    echo 'SayCV_MXE:$(PKG):Building DEVEL src.'; \
    $(call $(PKG)_BUILD_X,$(1),$(2),$($(PKG)_DIR_SRC)); \
	else \
	  echo 'SayCV_MXE:$(PKG):Build from RELEASE src.'; \
	  $(call $(PKG)_BUILD_X,$(1),$(2),$(1)); \
	fi
endef

define $(PKG)_BUILD_CFG
	rm -f '$(1).build/win32.cache'; \
  if ! test -f '$(1).build/win32.cache'; then \
      echo create win32.cache and prevent configure from changing it; \
    	mkdir -p '$(1).build'; \
    	cd '$(1).build' && touch win32.cache \
    	&& echo -e "glib_cv_long_long_format=I64" >> win32.cache \
    	&& echo -e "glib_cv_stack_grows=no" >> win32.cache \
    	&& chmod a-w win32.cache; \
  fi; \
	mkdir -p '$(1).build'; \
  $(SED) -i 's,aclocal,aclocal -I $(PREFIX)/$(TARGET)/share/aclocal,' '$($(PKG)_DIR_SRC)/autogen.sh'; \
  $(SED) -i 's,libtoolize,$(LIBTOOLIZE),'                             '$($(PKG)_DIR_SRC)/autogen.sh'; \
  cd    '$(1).build' && $(SHELL) '$(3)/autogen.sh' \
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

define $(PKG)_BUILD_X
  if ! test -f '$(PKG_DIR)/stamp_bootstrap_$(PKG)'; then \
		cd '$(3)' && ./bootstrap; \
	fi; \
	\
  if ! test -f '$(1).build/stamp_cfg_$($(PKG)_SUBDIR)'; then \
      $(call $(PKG)_BUILD_CFG,$(1),$(2),$(3)); \
  fi; \
  \
  if ! test -f '$(1).build/stamp_make_$($(PKG)_SUBDIR)'; then \
      $(MAKE) -C '$(1).build' -j '$(JOBS)' V=0 \
      && \
      cd '$(1).build' && touch 'stamp_make_$($(PKG)_SUBDIR)'; \
  fi; \
  \
  if ! test -f '$(1).build/stamp_install_$($(PKG)_SUBDIR)'; then \
      $(MAKE) -C '$(1).build' -j 1 install \
      && \
      cd '$(1).build' && touch 'stamp_install_$($(PKG)_SUBDIR)'; \
  fi
endef