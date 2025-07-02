##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Jul 3 08:57:07 2021
#  Last Modified : <210703.1318>
#
#  Description	
#
#  Notes
#
#  History
#	
#  $Log$
#
##############################################################################
#
#    Copyright (C) 2021  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
#
##############################################################################


SUBDIRS =
CODEFILES = $(wildcard *.h)
FIGURES = $(wildcard *.png)
OTHERFILES = Turnout1.xml Tower1.tcl 
EXTRA_DIST = $(OTHERFILES) $(CODEFILES) $(FIGURES) Doxyfile.in
pkgdatadir = $(datadir)/$(PACKAGE)/ExampleDataAndCode/LayoutControlDB
noinst_DATA = html/index.html
pkgdata_DATA =  $(CODEFILES) $(OTHERFILES) latex/refman.pdf

CLEANFILES= *.tag navheader.html

html/index.html latex/refman.pdf : Doxyfile $(CODEFILES) $(FIGURES) FORCE
	-rm -rf latex/ html/
	$(DOXYGEN) Doxyfile
	$(MAKE) -C latex pdf
	
FORCE:
	
clean-local:
	-rm -rf latex/ html/
	

install-data-hook: $(CODEFILES) $(OTHERFILES) html/index.html
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)
	for p in $(CODEFILES) $(OTHERFILES); do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/$$f'"; \
	  $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/$$f"; \
	done
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/html
	for p in html/*; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/html/$$f"; \
	  $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/html/$$f"; \
	done
	
uninstall-hook:
	for p in $(DESTDIR)$(pkgdatadir)/*; do \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " rm -f '$(DESTDIR)$(pkgdatadir)/$$f'"; \
	  rm -rf "$(DESTDIR)$(pkgdatadir)/$$f"; \
	done                                                         
	

