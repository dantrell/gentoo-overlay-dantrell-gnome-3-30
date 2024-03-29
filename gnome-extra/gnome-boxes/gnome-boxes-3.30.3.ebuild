# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"
VALA_MIN_API_VERSION="0.36"
VALA_MAX_API_VERSION="0.38"

inherit gnome2 linux-info readme.gentoo-r1 vala meson

DESCRIPTION="Simple GNOME application to access remote or virtual systems"
HOMEPAGE="https://wiki.gnome.org/Apps/Boxes"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

# We force 'bindist' due to licenses from gnome-boxes-nonfree
IUSE="" #bindist

# NOTE: sys-fs/* stuff is called via exec()
# FIXME: ovirt is not available in tree
# FIXME: use vala.eclass but only because of libgd not being able
#        to use its pre-generated files so do not copy all the
#        vala deps like live ebuild has.
# FIXME: qemu probably needs to depend on spice[smartcard]
#        directly with USE=spice
RDEPEND="
	>=app-arch/libarchive-3:=
	>=dev-libs/glib-2.52:2
	>=dev-libs/gobject-introspection-0.9.6:=
	>=dev-libs/libxml2-2.7.8:2
	>=sys-libs/libosinfo-1.1.0
	>=app-emulation/qemu-1.3.1[spice,smartcard,usbredir]
	>=app-emulation/libvirt-0.9.3[libvirtd,qemu]
	>=app-emulation/libvirt-glib-0.2.3
	>=x11-libs/gtk+-3.19.8:3
	>=net-libs/gtk-vnc-0.4.4[gtk3(+),vala]
	app-crypt/libsecret
	app-emulation/spice[smartcard]
	>=net-misc/spice-gtk-0.32[gtk3(+),smartcard,usbredir,vala]
	virtual/libusb:1

	>=app-misc/tracker-0.16:0=[iso]
	net-libs/webkit-gtk:4
	net-misc/freerdp

	>=net-libs/libsoup-2.44:2.4

	sys-fs/mtools
	>=dev-libs/libgudev-165:=
"
#	!bindist? ( gnome-extra/gnome-boxes-nonfree )

DEPEND="${RDEPEND}
	$(vala_depend)
	app-text/yelp-tools
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="Before running gnome-boxes, you will need to load the KVM modules.
If you have an Intel Processor, run:
# modprobe kvm-intel

If you have an AMD Processor, run:
# modprobe kvm-amd"

pkg_pretend() {
	linux-info_get_any_version

	if linux_config_exists; then
		if ! { linux_chkconfig_present KVM_AMD || \
			linux_chkconfig_present KVM_INTEL; }; then
			ewarn "You need KVM support in your kernel to use GNOME Boxes!"
		fi
	fi
}

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D ovirt=false
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	gnome2_pkg_postinst
	readme.gentoo_print_elog
}
