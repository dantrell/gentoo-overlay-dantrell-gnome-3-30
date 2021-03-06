# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 vala meson

DESCRIPTION="Clear hidden mines from a minefield"
HOMEPAGE="https://wiki.gnome.org/Apps/Mines"

LICENSE="GPL-3+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.40:2
	dev-libs/libgee:0.8
	>=x11-libs/gtk+-3.12:3
	dev-libs/libgnome-games-support:1=
	>=gnome-base/librsvg-2.32.0:2[vala]
"
DEPEND="${RDEPEND}
	$(vala_depend)
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}
