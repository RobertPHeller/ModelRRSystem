Robert Heller <support@deepsoft.com>
Deepwoods Software
51 Locke Hill Road
Wendell, MA 01379
978-544-6933
http://www.deepsoft.com/
http://www.deepsoft.com/ModelRailroadSystem

This archive contains the Win32 build of the current release of the Model
Railroad System cross-built under CentOS 5.  It was cross-built on a AMD Sempron
with the i586-mingw32 target. The binary distribution is in three
archives: Win32BinOnly, Win32BinDoc, Win32BinDevel archives.  The
Win32BinOnly archive contains the binary executables and support
libraries, the Win32BinDoc archive contains the built documentation
files (PDF and HTML), and the Win32BinDevel contains the files needed to
support development, including C++ headers and static libraries.

It has NOT be heavily tested (by me) under MS-Windows, since I don't
have a MS-Windows machine to test it on.  I have used wine to verify that
the executable files have basic functionallity. The executables don't
need to be installed anyplace in particular, since they are
self-contained Starpacks, containing all of their needed support files.
There is an installer program, named setup.exe, on the CD (or in the iso
file), that can be used to install both the base binary archives as well
as various additional packages (which includes the source code). The
installer program expects to be in the same directory as the archives it
installs. 

The MRD library in this package depends on libusb-1.0 and needs the
mingw32 libusb-1.0.dll installed (typically in C:\windows32).  This DLL
is available from http://www.libusb.org/wiki/windows_backend, with this
build using the MinGW32 binaries of the snapshot of 2011.11.02, so you
should download libusb_2011.11.02.7z and use the libusb-1.0.dll file in
the MinGW32/dll directory. You will also need to install the WinUSB
driver. 

