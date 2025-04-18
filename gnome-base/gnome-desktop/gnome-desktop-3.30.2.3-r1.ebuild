# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools gnome2 virtualx

DESCRIPTION="Libraries for the gnome desktop that are not part of the UI"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-desktop"

LICENSE="GPL-2+ FDL-1.1+ LGPL-2+"
SLOT="3/12" # subslot = libgnome-desktop-3 soname version
KEYWORDS="*"

IUSE="debug +introspection +seccomp udev vanilla-thumbnailer"

# cairo[X] needed for gnome-bg
# bubblewrap is automagic
# seccomp is automagic, though we want to use it whenever possible (linux)
COMMON_DEPEND="
	app-text/iso-codes
	>=dev-libs/glib-2.44.0:2[dbus]
	>=x11-libs/gdk-pixbuf-2.36.5:2[introspection?]
	>=x11-libs/gtk+-3.3.6:3[X,introspection?]
	x11-libs/cairo:=[X]
	x11-libs/libX11
	x11-misc/xkeyboard-config
	>=gnome-base/gsettings-desktop-schemas-3.27.0
	introspection? ( >=dev-libs/gobject-introspection-0.9.7:= )
	seccomp? ( >=sys-libs/libseccomp-2.0 )
	udev? ( virtual/libudev:= )
	vanilla-thumbnailer? ( sys-apps/bubblewrap )
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.1.2
	dev-util/gdbus-codegen
	>=dev-build/gtk-doc-am-1.14
	>=dev-util/intltool-0.40.6
	dev-util/itstool
	sys-devel/gettext
	x11-base/xorg-proto
	virtual/pkgconfig
"

# Includes X11/Xatom.h in libgnome-desktop/gnome-bg.c which comes from xproto

src_prepare() {
	eapply "${FILESDIR}"/patches/ # Requires eautoreconf. https://gitlab.gnome.org/Community/gentoo/gnome-desktop/compare/3.30.2.3...gentoo-3.30.2.3

	if ! use vanilla-thumbnailer; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/gnome-desktop/-/commit/8b1db18aa75c2684b513481088b4e289b5c8ed92
		eapply "${FILESDIR}"/${PN}-3.30.2.3-dont-sandbox-thumbnailers-on-linux.patch
	fi

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--with-gnome-distributor=Gentoo \
		--enable-desktop-docs \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable debug debug-tools) \
		$(use_enable introspection) \
		$(use_enable udev)
}

src_test() {
	virtx emake check
}
