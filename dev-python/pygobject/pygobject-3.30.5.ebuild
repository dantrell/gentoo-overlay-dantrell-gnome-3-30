# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{2_7,3_5,3_6,3_7,3_8} )

inherit meson python-r1 virtualx versionator

MY_PV=$(get_version_component_range 1-2)

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="https://wiki.gnome.org/Projects/PyGObject"
SRC_URI="https://download.gnome.org/sources/${PN}/${MY_PV}/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="*"

IUSE="+cairo test"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	test? ( cairo )
"

RESTRICT="!test? ( test )"

COMMON_DEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.38:2
	>=dev-libs/gobject-introspection-1.46.0:=
	virtual/libffi:=
	cairo? (
		>=dev-python/pycairo-1.11.1[${PYTHON_USEDEP}]
		x11-libs/cairo )
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	cairo? ( x11-libs/cairo[glib] )
	test? (
		dev-libs/atk[introspection]
		dev-python/pytest[${PYTHON_USEDEP}]
		media-fonts/font-cursor-misc
		media-fonts/font-misc-misc
		x11-libs/cairo[glib]
		x11-libs/gdk-pixbuf:2[introspection,jpeg]
		x11-libs/gtk+:3[introspection]
		x11-libs/pango[introspection]
		python_targets_python2_7? ( dev-python/pyflakes[$(python_gen_usedep python2_7)] ) )
"

# We now disable introspection support in slot 2 per upstream recommendation
# (see https://bugzilla.gnome.org/show_bug.cgi?id=642048#c9); however,
# older versions of slot 2 installed their own site-packages/gi, and
# slot 3 will collide with them.
RDEPEND="${COMMON_DEPEND}
	!<dev-python/pygtk-2.13
	!<dev-python/pygobject-2.28.6-r50:2[introspection]
"

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	glob() {
		local emesonargs=(
			-D python="${EPYTHON}"
			-D pycairo=$(usex cairo true false)
		)
		meson_src_configure
		meson_src_compile
		meson_src_install
	}
	python_foreach_impl glob
}
