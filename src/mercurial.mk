# This file is part of MXE.
# See index.html for further information.

PKG             := mercurial
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := aa1503c353370bafc90d79b9c682aae9c1001c3c
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://mercurial.selenic.com/release/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc

$(PKG)_BUILD_SRC     := 0
$(PKG)_DIR_SRC       := $(PKG_DIR)/$(PKG)
$(PKG)_GIT_URL_GIT   := $(GIT_GNU_GIT)/$(PKG)
$(PKG)_GIT_URL_HTTP  := $(GIT_GNU_HTTP)/$(PKG).git
$(PKG)_SRC_TYPE := git

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.selenic.com/mercurial/release/?M=D' | \
    grep '<a href=' | \
    $(SED) -n 's,.*<a[^>]*>\([0-9]*\.[0-9]*[02468]\.[^<]*\)<.*,\1,p' | \
    grep -v '^2\.9' | \
    grep '^2\.' | \
    head -1
endef

define $(PKG)_UPDATE_PATCH
    $(WGET) -q -O- 'http://$(SOURCEFORGE_MIRROR)/project/msysdev/ALL/m4/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="1.".*,\1,p' | \
    head -1
endef

define $(PKG)_GET_PATCH
	mkdir -p '$(PKG_DIR)' && cd '$(PKG_DIR)' && \
    $(WGET) -N -c -O- '1' \
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
    	mkdir -p '$(1)'; \
	    cd    '$(3)' && python setup.py build -f -c mingw32 install -f \
        	&&  \
      cd '$(1)' && touch 'stamp_cfg_$($(PKG)_SUBDIR)'; \
      cd '$(1)' && touch 'stamp_make_$($(PKG)_SUBDIR)'; \
      cd '$(1)' && touch 'stamp_install_$($(PKG)_SUBDIR)'
endef

define $(PKG)_BUILD_X
  if ! test -f '$(3)/stamp_bootstrap_$(PKG)'; then \
		cd '$(3)' && ./autoreconf && \
		touch 'stamp_bootstrap_$(PKG)'; \
	fi; \
	\
  if ! test -f '$(1)/stamp_cfg_$($(PKG)_SUBDIR)'; then \
      echo "SayCV_MXE: Configure."; \
      $(call $(PKG)_BUILD_CFG,$(1),$(2),$(3)); \
  fi; \
  \
  if ! test -f '$(1)/stamp_make_$($(PKG)_SUBDIR)'; then \
      echo "SayCV_MXE: make."; \
      $(MAKE) -C '$(1)' -j '$(JOBS)' V=0 PREFIX='$(PREFIX)' \
      && \
      cd '$(1)' && touch 'stamp_make_$($(PKG)_SUBDIR)'; \
  fi; \
  \
  if ! test -f '$(1)/stamp_install_$($(PKG)_SUBDIR)'; then \
      echo "SayCV_MXE: make install."; \
      $(MAKE) -C '$(1)' -j 1 install PREFIX='$(PREFIX)' \
      && \
      cd '$(1)' && touch 'stamp_install_$($(PKG)_SUBDIR)'; \
  fi
endef
