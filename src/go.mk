# This file is part of MXE.
# See index.html for further information.

PKG             := go
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := 73fff09786c68b9211a2ddf14c690fe374d15780
$(PKG)_SUBDIR   := $(PKG)
$(PKG)_FILE1    := $(PKG).weekly.2012-02-22.zip
$(PKG)_FILE2    := $(PKG)$($(PKG)_VERSION).windows-386.zip
$(PKG)_URL1     := https://gomingw.googlecode.com/files/$($(PKG)_FILE1)
$(PKG)_URL2     := https://go.googlecode.com/files/$($(PKG)_FILE2)
$(PKG)_FILE     := $($(PKG)_FILE2)
$(PKG)_URL      := $($(PKG)_URL2)
$(PKG)_DEPS     := unzip

$(PKG)_REPO_BUILD     := 0
$(PKG)_REPO_DIR       := $(PKG_DIR)/$(PKG)
$(PKG)_REPO_URL_1     := https://go.googlecode.com/hg/
$(PKG)_REPO_URL_2     := 
$(PKG)_REPO_CMD       := hg

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://code.google.com/p/go/downloads/list/?C=M;O=D' | \
    $(SED) -n 's,.*go\([0-9][^<]*\).*,\1,p' | \
    head -1
endef

define $(PKG)_UPDATE_PATCH
    $(WGET) -q -O- 'http://www.t.com/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="$(PKG)-$($(PKG)_VERSION)-\([0-9.]*\).tar.lzma".*,\1,p' | \
    head -1
endef

define $(PKG)_GET_PATCH
	mkdir -p '$(PKG_DIR)' && cd '$(PKG_DIR)' && \
    $(WGET) -N -c -O- 'http://www.t.com/$($(PKG)_PATCH_FILE)' \
		> '$($(PKG)_PATCH_FILE)'
endef

define $(PKG)_REPO_GET
    if ! [ -z '$($(PKG)_REPO_CMD)' ]; then \
      echo "$($(PKG)_REPO_CMD) clone src ...";  \
      cd $(PKG_DIR) && \
      '$($(PKG)_REPO_CMD)' clone $($(PKG)_REPO_URL_1) $(PKG); \
    fi
endef

define $(PKG)_BUILD
	if test '$($(PKG)_REPO_BUILD)' = '1'; then \
    echo 'SayCV_MXE:$(PKG):Build from DEVEL src.'; \
    echo 'SayCV_MXE:$(PKG):Get DEVEL src.'; \
    if ! test -d '$($(PKG)_REPO_DIR)'; then \
        $(call $(PKG)_REPO_GET,$(1),$(2)); \
    fi; \
    echo 'SayCV_MXE:$(PKG):Building DEVEL src.'; \
    $(call $(PKG)_BUILD_X,$(1),$(2),../../../pkg/$(PKG)); \
	else \
	  echo 'SayCV_MXE:$(PKG):Build from RELEASE src.'; \
	  $(call $(PKG)_BUILD_X,$(1),$(2),$(1)); \
	fi
endef

define $(PKG)_BUILD_CFG
      $(INSTALL) -d '$(PREFIX)/opt/go'; \
      cd '$(1)' && \
        cp -rpv * '$(PREFIX)/opt/go'; \
      cd '$(1)' && touch 'stamp_cfg_$($(PKG)_SUBDIR)'; \
      cd '$(1)' && touch 'stamp_make_$($(PKG)_SUBDIR)'; \
      cd '$(1)' && touch 'stamp_install_$($(PKG)_SUBDIR)'
endef

define $(PKG)_BUILD_X
  if ! test -f '$(1)/stamp_cfg_$($(PKG)_SUBDIR)'; then \
      echo "SayCV_MXE: Configure."; \
      $(call $(PKG)_BUILD_CFG,$(1),$(2),$(3)); \
  fi; \
  \
  if ! test -f '$(1)/stamp_make_$($(PKG)_SUBDIR)'; then \
      echo "SayCV_MXE: make."; \
      $(MAKE) -C '$(1)' -j '$(JOBS)' V=0 \
      && \
      cd '$(1)' && touch 'stamp_make_$($(PKG)_SUBDIR)'; \
  fi; \
  \
  if ! test -f '$(1)/stamp_install_$($(PKG)_SUBDIR)'; then \
      echo "SayCV_MXE: make install."; \
      $(MAKE) -C '$(1)' -j 1 install \
      && \
      cd '$(1)' && touch 'stamp_install_$($(PKG)_SUBDIR)'; \
  fi
endef