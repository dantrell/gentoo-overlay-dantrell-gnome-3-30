# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{2_7,3_6,3_7,3_8,3_9} )

inherit meson python-r1 virtualx versionator

MY_PV=$(get_version_component_range 1-2)

DESCRIPTION="Python bindings for GObject Introspection"
HOMEPAGE="https://pygobject.readthedocs.io/"
SRC_URI="https://download.gnome.org/sources/${PN}/${MY_PV}/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="*"

IUSE="+cairo"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="test"

COMMON_DEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.38:2
	>=dev-libs/gobject-introspection-1.46.0:=
	dev-libs/libffi:=
	cairo? (
		>=dev-python/pycairo-1.11.1[${PYTHON_USEDEP}]
		x11-libs/cairo )
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	cairo? ( x11-libs/cairo[glib] )
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
