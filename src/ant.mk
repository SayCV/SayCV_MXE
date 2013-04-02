# This file is part of MXE.
# See index.html for further information.

PKG             := ant
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := 791418e7e80e3f28d6347528e8992a14f09058e7
$(PKG)_SUBDIR   := apache-$(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE1    := apache-$(PKG)-$($(PKG)_VERSION)-bin.tar.gz
$(PKG)_FILE2    := 
$(PKG)_URL1     := http://labs.mop.com/apache-mirror//ant/binaries/$($(PKG)_FILE1)
$(PKG)_URL2     := http://ant.apache.org
$(PKG)_FILE     := $($(PKG)_FILE1)
$(PKG)_URL      := $($(PKG)_URL1)
$(PKG)_DEPS     := 

$(PKG)_REPO_BUILD     := 0
$(PKG)_REPO_DIR       := $(PKG_DIR)/$(PKG)
$(PKG)_REPO_URL_1     := https://
$(PKG)_REPO_URL_2     := 
$(PKG)_REPO_CMD       := hg

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https:///?C=M;O=D' | \
    $(SED) -n 's,.*go\([0-9][^<]*\).*,\1,p' | \
    head -1
endef

define $(PKG)_UPDATE_PATCH
    $(WGET) -q -O- 'http:///?C=M;O=D' | \
    $(SED) -n 's,.*<a href="$(PKG)-$($(PKG)_VERSION)-\([0-9.]*\).tar.lzma".*,\1,p' | \
    head -1
endef

define $(PKG)_GET_PATCH
	mkdir -p '$(PKG_DIR)' && cd '$(PKG_DIR)' && \
    $(WGET) -N -c -O- 'http:///$($(PKG)_PATCH_FILE)' \
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
      $(INSTALL) -d '$(PREFIX)/opt/ant'; \
      cd '$(1)' && \
        cp -rpv * '$(PREFIX)/opt/ant'; \
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