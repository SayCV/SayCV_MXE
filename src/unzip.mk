# This file is part of MXE.
# See index.html for further information.

PKG             := unzip
$(PKG)_IGNORE   := 
$(PKG)_CHECKSUM := abf7de8a4018a983590ed6f5cbd990d4740f8a22
$(PKG)_SUBDIR   := unzip60
$(PKG)_FILE     := unzip60.tar.gz
$(PKG)_URL      := http://$(SOURCEFORGE_MIRROR)/project/infozip/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz
$(PKG)_DEPS     := zlib

define $(PKG)_UPDATE
    echo $($(PKG)_VERSION)
endef

define $(PKG)_BUILD
	# apply patch
	if ! test -f '$(1)/stamp_patch_$($(PKG)_SUBDIR)'; then \
		$(foreach PKG_PATCH,$(sort $(wildcard $(1)/win32-experimental/*w32*patch*.txt)),\
			(cd '$(1)' && $(PATCH) -p1 -u) < $(PKG_PATCH);) \
		cd '$(1)' && touch 'stamp_patch_$($(PKG)_SUBDIR)'; \
	fi
	
	# build and install
	# globals.h move int      disk_full; to after /* !FUNZIP */ at about lines 316.
	if ! test -f '$(1)/stamp_install_$($(PKG)_SUBDIR)'; then \
		$(MAKE) -C '$(1)' -f win32/makefile.gcc -j 1 clean; \
		$(MAKE) -C '$(1)' -f win32/makefile.gcc NO_ZIP64_SUPPORT=1 -j '$(JOBS)' && \
		cd '$(1)' && cp -p unzip.exe '$(PREFIX)/bin' && cp -p unzipsfx.exe '$(PREFIX)/bin' && cp -p funzip.exe '$(PREFIX)/bin' && \
		cd '$(1)' && touch 'stamp_install_$($(PKG)_SUBDIR)'; \
	fi
	# cd '$(1)/$($(PKG)_SUBDIR)win32/' && make -f win32/makefile.gcc
endef