# This file is part of MXE.
# See index.html for further information.

PKG             := make
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := 92d1b87a30d1c9482e52fb4a68e8a355e7946331
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := $(PKG_GNU)/$(PKG)/$($(PKG)_FILE)
$(PKG)_DEPS     := 
 
$(PKG)_BUILD_SRC     := 0
$(PKG)_DIR_SRC       := $(PKG_DIR)/$(PKG)
$(PKG)_GIT_URL_GIT   := $(GIT_GNU_GIT)/$(PKG)
$(PKG)_GIT_URL_HTTP  := $(GIT_GNU_HTTP)/$(PKG).git
$(PKG)_SRC_TYPE := git

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://ftp.gnu.org/gnu/m4' | \
    $(SED) -n 's,.*m4-\([0-9][^<]*\).*,\1,p' | \
    head -1
endef

define $(PKG)_UPDATE_PATCH
    $(WGET) -q -O- 'http://$(SOURCEFORGE_MIRROR)/project/msysdev/ALL/m4/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="m4-$(m4_VERSION)-1-msys-\([0-9.]*\).tar.lzma".*,\1,p' | \
    head -1
endef

define $(PKG)_GET_PATCH
	mkdir -p '$(PKG_DIR)' && cd '$(PKG_DIR)' && \
    $(WGET) -N -c -O- 'http://$(SOURCEFORGE_MIRROR)/project/msysdev/ALL/m4/m4-$($(PKG)_VERSION)/$($(PKG)_PATCH_FILE)' \
		> '$($(PKG)_PATCH_FILE)'
endef

define $(PKG)_SRC_GET
    if test '$($(PKG)_SRC_TYPE)' == 'git'; then \
      echo "git clone src ...";  \
      cd $(PKG_DIR) && \
      git clone $($(PKG)_GIT_URL_GIT) $(PKG); \
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
    $(call $(PKG)_BUILD_X,$(1),$(2),../../../pkg/$(PKG)); \
	else \
	  echo 'SayCV_MXE:$(PKG):Build from RELEASE src.'; \
	  $(call $(PKG)_BUILD_X,$(1),$(2),$(1)); \
	fi
endef

define $(PKG)_BUILD_CFG
    	mkdir -p '$(1).build'; \
	    cd    '$(1).build' && '$(3)/configure' \
        	--target='$(TARGET)' \
        	--build="`config.guess`" \
        	--prefix='$(PREFIX)' \
        	--disable-assert \
        	--disable-rpath \
        	&&  \
      cd '$(1).build' && touch 'stamp_cfg_$($(PKG)_SUBDIR)'
endef

define $(PKG)_BUILD_X
  if ! test -f '$(3)/stamp_bootstrap_$(PKG)'; then \
		cd '$(3)' && ./bootstrap && \
		touch 'stamp_bootstrap_$(PKG)'; \
	fi; \
	\
  if ! test -f '$(1).build/stamp_cfg_$($(PKG)_SUBDIR)'; then \
      echo "SayCV_MXE: Configure."; \
      $(call $(PKG)_BUILD_CFG,$(1),$(2),$(3)); \
  fi; \
  \
  if ! test -f '$(1).build/stamp_make_$($(PKG)_SUBDIR)'; then \
      echo "SayCV_MXE: make."; \
      $(MAKE) -C '$(1).build' -j '$(JOBS)' V=0 \
      && \
      cd '$(1).build' && touch 'stamp_make_$($(PKG)_SUBDIR)'; \
  fi; \
  \
  if ! test -f '$(1).build/stamp_install_$($(PKG)_SUBDIR)'; then \
      echo "SayCV_MXE: make install."; \
      echo "$(MAKE) -C '$(1).build' -j 1 install install-binPROGRAMS" \
      && \
      cd '$(1).build' && touch 'stamp_install_$($(PKG)_SUBDIR)'; \
  fi
endef