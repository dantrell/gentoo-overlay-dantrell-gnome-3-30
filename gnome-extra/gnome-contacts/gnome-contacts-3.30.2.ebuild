# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala meson

DESCRIPTION="GNOME contact management application"
HOMEPAGE="https://wiki.gnome.org/Design/Apps/Contacts"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="doc +telepathy v4l"

VALA_DEPEND="
	$(vala_depend)
	>=dev-libs/gobject-introspection-0.9.6:=
	dev-libs/folks[vala(+)]
	gnome-base/gnome-desktop:3=[introspection]
	gnome-extra/evolution-data-server[vala]
	net-libs/telepathy-glib[vala]
"
# Configure is wrong; it needs cheese-3.5.91, not 3.3.91
RDEPEND="
	>=dev-libs/folks-0.11.4:=[eds,telepathy?]
	>=dev-libs/libgee-0.10:0.8
	>=dev-libs/glib-2.44:2
	>=gnome-base/gnome-desktop-3.0:3=
	net-libs/gnome-online-accounts:=[vala]
	>=x11-libs/gtk+-3.22:3
	>=gnome-extra/evolution-data-server-3.13.90:=[gnome-online-accounts]
	doc? ( dev-util/valadoc )
	v4l? ( >=media-video/cheese-3.3.91:= )
	telepathy? ( >=net-libs/telepathy-glib-0.22 )
"
DEPEND="${RDEPEND}
	${VALA_DEPEND}
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xsl-stylesheets
	dev-libs/libxml2
	dev-libs/libxslt
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gnome-contacts/commit/1b738cec18c159a71334f6563ad0f197e675d2cb
	eapply "${FILESDIR}"/${PN}-9999-fix-the-valadoc-build.patch

	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D cheese=$(usex v4l true false)
		-D telepathy=$(usex telepathy true false)
		-D manpage=true
		-D docs=$(usex doc true false)
	)
	meson_src_configure
}
