%define ver  2.1.6
Summary: Model Railroad System
Name: MRRSystem
Version: %ver
Release: 1
Group: Applications/Engineering
Copyright: GPL
Packager: Robert Heller <heller@deepsoft.com>
URL: http://www.deepsoft.com/MRRSystem/
Source: ftp://ftp.deepsoft.com/pub/deepwoods/Products/MRRSystem/MRRSystem-2.1.6.tar.gz
BuildRoot: /var/tmp/%{name}-root
Requires: bwidget, tcllib >= 1.8, tcl, tk, libusb
BuildRequires: doc++ >= 3.4, tcl-devel >= 8.3, bison++, swig >= 1.1
BuildRequires: libusb-devel >= 0.1.10
%description
The Model Railroad System contains programs and libraries to support
various model railroad activities, including operating the model
railroad itself, freight car forwarding, time table creating, and
dealing with some of the design work as well.


%package doc
Summary: Model Railroad System Documentation
Group: Applications/Engineering
%description doc
The Model Railroad System contains programs and libraries to support
various model railroad activities, including operating the model
railroad itself, freight car forwarding, time table creating, and
dealing with some of the design work as well. This is the documentation
package.


%prep
%setup -q

%build
sh configure --prefix=/usr
make

%install
rm -rf $RPM_BUILD_ROOT/usr
rm -rf $RPM_BUILD_ROOT/etc
make DESTDIR=$RPM_BUILD_ROOT install
/usr/bin/install -d $RPM_BUILD_ROOT/etc/hotplug/usb
/usr/bin/install -c $RPM_BUILD_ROOT/usr/share/MRRSystem-%{ver}/RailDriver/raildriverd.hotplug $RPM_BUILD_ROOT/etc/hotplug/usb/raildriverd


%clean
rm -rf $RPM_BUILD_ROOT

%post 
grep -v raildriverd /etc/hotplug/usb.usermap > /etc/hotplug/usb.usermap.tmp
/usr/share/MRRSystem-%{ver}/RailDriver/print-usb-usermap >> /etc/hotplug/usb.usermap.tmp
mv /etc/hotplug/usb.usermap.tmp /etc/hotplug/usb.usermap
# register libraries
/sbin/ldconfig

%postun 
/sbin/ldconfig
if [ "$1" = 0 ]; then
    # remove supported cameras from /etc/hotplug/usb.usermap
    grep -v 'raildriverd' /etc/hotplug/usb.usermap > /etc/hotplug/usb.usermap.new
    mv /etc/hotplug/usb.usermap.new /etc/hotplug/usb.usermap
fi


%files
%defattr(-, root, root)

%doc AUTHORS COPYING INSTALL NEWS README ChangeLog
/usr/lib/*
/usr/sbin/raildriverd
/usr/bin/UniversalTest
/usr/bin/AnyDistance
/usr/bin/Closest
/usr/bin/FCFMain
/usr/bin/TTChart2TT2
/usr/bin/TimeTable
/usr/bin/LocoTest
/usr/share/MRRSystem-%{ver}/Swig/*
/usr/share/MRRSystem-%{ver}/Help/*
/usr/share/MRRSystem-%{ver}/Common/*
/usr/share/MRRSystem-%{ver}/GRSupport/*
/usr/share/MRRSystem-%{ver}/TimeTable/*
/usr/share/MRRSystem-%{ver}/FCFScripts/*
/usr/share/MRRSystem-%{ver}/TTScripts/*
/usr/share/MRRSystem-%{ver}/RailDriver/*
/etc/hotplug/usb/raildriverd

%files doc
%defattr(-, root, root)

/usr/share/MRRSystem-%{ver}/Doc/*



