EXTRA_DIST=Img-1.3-Mac-Universal.zip Img-1.3-Linux32.zip Img-1.3-Linux64.zip \
	   Img-1.3-win32.zip tclkit-darwin-univ-aqua tclkit-linux-x86 \
	   tclkit-linux-x86_64 tclkit-win32.exe pdf4tcl05.zip

BUILT_SOURCES = tclkit${BEXEEXT}

noinst_SCRIPTS = tclkit${BEXEEXT}

EXTRA_SCRIPTS = tclkit-darwin-univ-aqua tclkit-linux-x86 tclkit-linux-x86_64 \
		 tclkit-win32.exe
bin_SCRIPTS = $(TCLKITRUN)
pkglib_DATA = $(IMG_ZIP)

tclkit${BEXEEXT}: $(TCLKITBSRC) $(top_builddir)/config.status
	cp $(srcdir)/$(TCLKITBSRC) ./tclkit${BEXEEXT}

FORCE:

