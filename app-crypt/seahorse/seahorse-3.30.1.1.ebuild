# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson vala

DESCRIPTION="A GNOME application for managing encryption keys"
HOMEPAGE="https://wiki.gnome.org/Apps/Seahorse"

LICENSE="GPL-2+ FDL-1.1+"
SLOT="0"
KEYWORDS="*"

IUSE="doc ldap zeroconf"

COMMON_DEPEND="
	>=app-crypt/gcr-3.11.91:=
	>=app-crypt/gnupg-2.0.12
	>=app-crypt/gpgme-1
	>=app-crypt/libsecret-0.16
	>=dev-libs/glib-2.10:2
	>=net-libs/libsoup-2.33.92:2.4
	net-misc/openssh
	>=x11-libs/gtk+-3.4:3
	x11-misc/shared-mime-info

	ldap? ( net-nds/openldap:= )
	zeroconf? ( >=net-dns/avahi-0.6:=[dbus] )
"
DEPEND="${COMMON_DEPEND}
	$(vala_depend)
	app-text/yelp-tools
	dev-util/gdbus-codegen
	>=dev-util/intltool-0.35
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
"
# Need seahorse-plugins git snapshot
RDEPEND="${COMMON_DEPEND}
	!<app-crypt/seahorse-plugins-2.91.0_pre20110114
"

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D help=$(usex doc true false)
		-D pgp-support=true
		-D check-compatible-gpg=true
		-D pkcs11-support=true
		-D keyservers-support=true
		-D hkp-support=true
		-D ldap-support=$(usex ldap true false)
		-D key-sharing=$(usex zeroconf true false)
	)
	meson_src_configure
}
