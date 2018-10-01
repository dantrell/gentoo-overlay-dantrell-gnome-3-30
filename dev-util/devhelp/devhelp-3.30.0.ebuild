# Distributed under the terms of the GNU General Public License v2

EAPI="6"
# gedit-3.8 is python3 only, this also per:
# https://bugzilla.redhat.com/show_bug.cgi?id=979450
PYTHON_COMPAT=( python{3_4,3_5,3_6,3_7} )

inherit gnome2 python-single-r1 toolchain-funcs meson

DESCRIPTION="An API documentation browser for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Devhelp"

LICENSE="GPL-2+"
SLOT="0/3-4" # subslot = 3-(libdevhelp-3 soname version)
KEYWORDS="*"

IUSE="doc"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="
	>=dev-libs/glib-2.56:2[dbus]
	>=x11-libs/gtk+-3.22:3
	>=net-libs/webkit-gtk-2.20:4
	gnome-base/gsettings-desktop-schemas
	>=dev-libs/gobject-introspection-1.30:=
	>=dev-libs/amtk-5.0
"
RDEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	app-editors/gedit[introspection,python,${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	x11-libs/gtk+[introspection]
"
# libxml2 required for glib-compile-resources
DEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	dev-libs/libxml2:2
	>=dev-util/gtk-doc-am-1.25
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_configure() {
	local emesonargs=(
		-D flatpak_build=false
		-D gtk_doc=$(usex doc true false)
	)
	meson_src_configure
}