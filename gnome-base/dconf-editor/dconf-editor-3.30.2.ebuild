# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_MIN_API_VERSION="0.40"
VALA_MAX_API_VERSION="0.42"

inherit gnome2 meson vala

DESCRIPTION="Graphical tool for editing the dconf configuration database"
HOMEPAGE="https://gitlab.gnome.org/GNOME/dconf-editor"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	>=gnome-base/dconf-0.26.1
	>=dev-libs/glib-2.55.1:2
	>=x11-libs/gtk+-3.22.27:3
"
DEPEND="${RDEPEND}
	$(vala_depend)
	dev-libs/libxml2:2
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}
