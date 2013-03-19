# This file is part of MXE.
# See index.html for further information.

PKG             := m4
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := 44b3ed8931f65cdab02aee66ae1e49724d2551a4
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_PATCH_VERSION := 
$(PKG)_PATCH_FILE    := m4-$($(PKG)_VERSION)-1-msys-1.0.17-patch.tar.lzma
$(PKG)_URL      := $(PKG_GNU)/$(PKG)/$($(PKG)_FILE)
$(PKG)_DEPS     := 

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

# cd    '$(1)' && autoreconf -fvi
define $(PKG)_BUILD_1
	
	# download patch
	if ! test -f '$(PKG_DIR)/$($(PKG)_PATCH_FILE)'; then \
		$(call $(PKG)_GET_PATCH); \
		cd '$(PKG_DIR)' && xz -dc -F lzma '$($(PKG)_PATCH_FILE)' | tar xf -; \
	fi
	
	# apply patch
	if ! test -f '$(1)/stamp_pkg_patch_$($(PKG)_SUBDIR)'; then \
		$(foreach PKG_PATCH,$(sort $(wildcard $(PKG_DIR)/m4-*.patch)),\
			(cd '$(1)' && $(PATCH) -p1 -u) < $(PKG_PATCH);) \
		cd '$(1)' && touch 'stamp_pkg_patch_$($(PKG)_SUBDIR)'; \
	fi
	
	if ! test -f '$(1).build/stamp_cfg_$($(PKG)_SUBDIR)'; then \
		cd    '$(1)' && autoreconf -fvi; \
    	mkdir -p '$(1).build'; \
	    cd    '$(1).build' && '../m4-1.4.16/configure' \
        	--target='$(TARGET)' \
        	--build="`config.guess`" \
        	--prefix='$(PREFIX)' \
        	--disable-assert \
        	--disable-rpath \
        	CFLAGS=-D__MSYS__ &&  \
		cd '$(1).build' && touch 'stamp_cfg_$($(PKG)_SUBDIR)'; \
    fi
    $(MAKE) -C '$(1).build' -j '$(JOBS)' V=0
    $(MAKE) -C '$(1).build' -j 1         install
endef

define $(PKG)_BUILD
	
	if ! test -f '$(1).build/stamp_cfg_$($(PKG)_SUBDIR)'; then \
		cd    '$(1)' && autoreconf -fvi; \
    	mkdir -p '$(1).build'; \
	    cd    '$(1).build' && '../m4-1.4.16/configure' \
        	--target='$(TARGET)' \
        	--build="`config.guess`" \
        	--prefix='$(PREFIX)' \
        	--disable-assert \
        	--disable-rpath \
        	CFLAGS=-D__MSYS__ &&  \
		cd '$(1).build' && touch 'stamp_cfg_$($(PKG)_SUBDIR)'; \
    fi
    $(MAKE) -C '$(1).build' -j '$(JOBS)' V=0
    $(MAKE) -C '$(1).build' -j 1         install
endef
