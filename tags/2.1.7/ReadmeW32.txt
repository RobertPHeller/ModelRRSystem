Robert Heller <support@deepsoft.com>
Deepwoods Software
51 Locke Hill Road
Wendell, MA 01379
978-544-6933
http://www.deepsoft.com/
http://www.deepsoft.com/MRRSystem

This archive contains the Win32 build of the 2.1.7 release of the Model
Railroad System cross-built under CentOS 4.4 ix86.  It was build on a AMD K6
with the default i386 target.

It has NOT be tested (by me) under MS-Windows, since I don't have a
MS-Windows machine to test it on.

Release notes for 2.1.7 (From the ChangeLog):

Fri Feb  2 09:54:14 2007:

   2.1.7 Released:

	Many fixes to configure scripts and makefiles (many parts of
the build process have been fixed) to allow for cross-building for
MS-Windows, as well as more intelligent building under other systems. 
Someday I need to get a MacOSX build box and do a build for MacOSX.

	All Tcl/Tk code has been converted/adapted to the use of
StarKits and StarPacks for all platforms.  All Tcl coded build scripts
are now StarKits. All Tcl/Tk *programs* are now built as StarPack
executables.  Tcl/Tk does not need to be installed on the target system
and the StarPack executables can be copied as loose executable files,
without needing any support code installed (which facilitates installing
on dedicated machines, such as a yard boss's desktop or laptop).  Tcl
and Tk (with their development packages) are needed on the build
system, along with the BWidget and Snit extensions. And the Sdx kit is
needed as well as both native and target system TclKit executables.

	The C/C++ has been reorganized.  The C/C++ libraries are now
also the Tcl sharable load modules.  The Parser and Classes libraries
have been combined into a single library (eliminating the circular
dependency).  The separate Swig directory has been eliminated and the
Swig interface files (*.i) have been moved to the regular C/C++
subdirectories.  The C/C++ header files are now installed, so it is
possible to write C/C++ code on top of these libraries.

	Some of the Tcl/Tk code has been updated to make use of Snit
and/or BWidget.  The older version is still available, at least for the
time being.






