EXTRA_DIST=Img-1.3-Mac-Universal.zip Img-1.3-Linux32.zip Img-1.3-Linux64.zip \
	   Img-1.3-win32.zip tclkit-darwin-univ-aqua tclkit-linux-x86 \
	   tclkit-linux-x86_64 tclkit-win32.exe pdf4tcl05.zip

BUILT_SOURCES = tclkit${BEXEEXT}

noinst_SCRIPTS = tclkit${BEXEEXT}

EXTRA_SCRIPTS = tclkit-darwin-univ-aqua tclkit-linux-x86 tclkit-linux-x86_64 \
		 tclkit-win32.exe
bin_SCRIPTS = $(TCLKITRUN)
noinst_DATA = $(IMG_ZIP)

install-data-hook: $(IMG_ZIP)
	test -z "$(pkglibdir)" || $(mkdir_p) "$(DESTDIR)$(pkglibdir)"
	@list='$(IMG_ZIP)'; for p in $$list; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=$(am__strip_dir) \
	  echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkglibdir)/$$f'"; \
	  $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkglibdir)/$$f"; \
	done

tclkit${BEXEEXT}: $(TCLKITBSRC) $(top_builddir)/config.status
	cp $(srcdir)/$(TCLKITBSRC) ./tclkit${BEXEEXT}

FORCE:

