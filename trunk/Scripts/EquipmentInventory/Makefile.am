##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Jul 31 14:57:24 2021
#  Last Modified : <230530.1007>
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


EquipmentInventoryScripts  = ZipArchive.tcl RollingStock.tcl \
	RollingStockEditor.tcl


TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

bin_SCRIPTS = EquipmentInventory$(EXEEXT)

EXTRA_DIST  = EquipmentInventory.tcl $(EquipmentInventoryScripts) 
#EXTRA_DIST +=	EquipmentInventory.desktop EquipmentInventory.png



desktopdir = $(datadir)/applications
#desktop_DATA = EquipmentInventory.desktop

pixmapdir = $(datadir)/pixmaps
#pixmap_DATA = EquipmentInventory.png

man_MANS = man1/EquipmentInventory.1

pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = EquipmentInventory.pot

CLEANFILES = EquipmentInventory.kit $(bin_SCRIPTS) EquipmentInventory.pot

EquipmentInventory.pot: EquipmentInventory.tcl $(EquipmentInventoryScripts) \
			$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl \
		$(addprefix $(subdir)/,EquipmentInventory.tcl $(EquipmentInventoryScripts)) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for Equipment Inventory/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >EquipmentInventory.pot
	    
EquipmentInventoryCommonScripts = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
	$(top_srcdir)/Scripts/Common/new.gif \
	$(top_srcdir)/Scripts/Common/open.gif \
	$(top_srcdir)/Scripts/Common/close.gif \
	$(top_srcdir)/Scripts/Common/save.gif \
	$(top_srcdir)/Scripts/Common/print.gif \
	$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
	$(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
	$(top_srcdir)/Scripts/Common/splash.tcl \
	$(top_srcdir)/Scripts/Common/mainwindow.tcl \
	$(top_srcdir)/Scripts/Common/snitLFs.tcl \
	$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
	$(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
	$(top_srcdir)/Scripts/Common/snitdialog.tcl \
	$(top_srcdir)/Scripts/Common/snitlistbox.tcl \
	$(top_srcdir)/Scripts/Common/snitrotext.tcl \
	$(top_srcdir)/Scripts/Common/snitscrollableframe.tcl \
	$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
	$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
	$(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
	$(top_srcdir)/Scripts/Common/gettext.tcl \
	$(top_builddir)/Scripts/Common/Version.tcl \
	$(top_srcdir)/Scripts/Common/gray50.xbm \
	$(top_srcdir)/Scripts/Common/info.xbm \
	$(top_srcdir)/Scripts/Common/questhead.xbm \
	$(top_srcdir)/Scripts/Common/openfold.png \
	$(top_srcdir)/Scripts/Common/palette.png \
	$(top_srcdir)/Scripts/Common/unknown.xpm

EquipmentInventory${EXEEXT} : EquipmentInventory.tcl \
		$(EquipmentInventoryScripts) \
		$(EquipmentInventoryCommonScripts) \
		$(top_builddir)/Doc/User/EI/index.html \
		$(top_builddir)/po/EquipmentInventory/msgfiles
	-rm -rf EquipmentInventory.vfs EquipmentInventory.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/EquipmentInventory.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap EquipmentInventory.kit
	-rm -rf EquipmentInventory.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit EquipmentInventory \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit EquipmentInventory \
		lib $(CSVLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) \
		EquipmentInventory lib/EILib $(EquipmentInventoryScripts) \
			$(EquipmentInventoryCommonScripts)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit \
		EquipmentInventory EILib
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit \
		EquipmentInventory Help $(top_builddir)/Doc/User/EI/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit \
		EquipmentInventory Messages \
		$(top_builddir)/po/EquipmentInventory/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap \
		EquipmentInventory${EXEEXT} -runtime \
			$(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf EquipmentInventory.vfs EquipmentInventory.kit

$(top_builddir)/Doc/User/EI/index.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User EI/index.html
	
$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}
	

$(top_builddir)/po/EquipmentInventory/msgfiles: FORCE
	$(MAKE) -C $(top_builddir)/po/EquipmentInventory msgfiles
	
FORCE:

man1/EquipmentInventory.1: Doxyfile EquipmentInventory.tcl
	-rm -rf man1
	$(DOXYGEN)
	
clean-local:
	-rm -rf man1
