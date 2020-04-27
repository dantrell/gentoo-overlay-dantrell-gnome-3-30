# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org gnome2-utils meson virtualx xdg

DESCRIPTION="Gnome install & update software"
HOMEPAGE="https://wiki.gnome.org/Apps/Software"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~*"

IUSE="+firmware gnome gtk-doc packagekit spell udev"

RESTRICT="test"

RDEPEND="
	>=dev-libs/appstream-glib-0.7.14:0
	>=x11-libs/gdk-pixbuf-2.32.0:2
	>=dev-libs/glib-2.56:2
	>=x11-libs/gtk+-3.22.4:3
	>=dev-libs/json-glib-1.2.0
	app-crypt/libsecret
	>=net-libs/libsoup-2.52.0:2.4
	gnome? ( >=gnome-base/gnome-desktop-3.18.0:3= )
	spell? ( app-text/gspell:= )
	sys-auth/polkit
	packagekit? ( >=app-admin/packagekit-base-1.1.0 )
	firmware? ( >=sys-apps/fwupd-1.0.3 )
	udev? ( dev-libs/libgudev )
	>=gnome-base/gsettings-desktop-schemas-3.11.5
"
DEPEND="${RDEPEND}
	dev-libs/libxml2:2
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	gtk-doc? (
		dev-util/gtk-doc
		app-text/docbook-xml-dtd:4.3 )
"

src_prepare() {
	xdg_src_prepare
	sed -i -e '/install_data.*README\.md.*share\/doc\/gnome-software/d' meson.build || die
}

src_configure() {
	local emesonargs=(
		-Dtests=false
		$(meson_use spell gspell)
		$(meson_use gnome gnome_desktop) # Investigate purpose, in relation to shell_extensions too (is it ok to be same USE?)
		-Dman=true
		$(meson_use packagekit)
		# -Dpackagekit_autoremove
		-Dpolkit=true
		$(meson_use firmware fwupd)
		-Dflatpak=false
		-Drpm_ostree=false
		-Dsteam=false
		$(meson_use gnome shell_extensions) # Maybe gnome-shell USE?
		-Dodrs=false
		-Dubuntuone=false
		-Dubuntu_reviews=false
		-Dwebapps=true
		$(meson_use udev gudev)
		-Dsnap=false
		-Dexternal_appstream=false
		-Dvalgrind=false
		$(meson_use gtk-doc gtk_doc)
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
