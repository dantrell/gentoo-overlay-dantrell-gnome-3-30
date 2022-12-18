# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit gnome2 systemd meson

DESCRIPTION="Virtual filesystem implementation for GIO"
HOMEPAGE="https://wiki.gnome.org/Projects/gvfs"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="afp archive bluray cdda elogind fuse google gnome-keyring gnome-online-accounts gphoto2 gtk +http ios mtp nfs policykit samba systemd test +udev udisks zeroconf"
REQUIRED_USE="
	?? ( elogind systemd )
	cdda? ( udev )
	elogind? ( udisks )
	google? ( gnome-online-accounts )
	mtp? ( udev )
	udisks? ( udev )
	systemd? ( udisks )
"

# Tests with multiple failures, this is being handled upstream at:
# https://bugzilla.gnome.org/700162
RESTRICT="test"

RDEPEND="
	app-crypt/gcr:0=
	>=dev-libs/glib-2.51:2
	dev-libs/libxml2:2
	net-misc/openssh
	afp? ( >=dev-libs/libgcrypt-1.2.2:0= )
	archive? ( app-arch/libarchive:= )
	bluray? ( media-libs/libbluray:= )
	elogind? ( >=sys-auth/elogind-229:0= )
	fuse? ( >=sys-fs/fuse-2.8.0:0 )
	gnome-keyring? ( app-crypt/libsecret )
	gnome-online-accounts? ( >=net-libs/gnome-online-accounts-3.7.1:= )
	google? (
		>=dev-libs/libgdata-0.17.7:=[crypt,gnome-online-accounts]
		>=net-libs/gnome-online-accounts-3.17.1:= )
	gphoto2? ( >=media-libs/libgphoto2-2.5.0:= )
	gtk? ( >=x11-libs/gtk+-3.0:3 )
	http? ( >=net-libs/libsoup-2.42:2.4 )
	ios? (
		>=app-pda/libimobiledevice-1.2:=
		>=app-pda/libplist-1:= )
	mtp? (
		virtual/libusb:1
		>=media-libs/libmtp-1.1.12 )
	nfs? ( >=net-fs/libnfs-1.9.8:= )
	policykit? (
		>=sys-auth/polkit-0.114
		sys-libs/libcap )
	samba? (
		sys-libs/libunwind:=
		>=net-fs/samba-4[client] )
	systemd? ( >=sys-apps/systemd-206:0= )
	udev? (
		cdda? ( dev-libs/libcdio-paranoia )
		>=dev-libs/libgudev-147:=
		virtual/libudev:= )
	udisks? ( >=sys-fs/udisks-1.97:2 )
	zeroconf? ( >=net-dns/avahi-0.6[dbus] )
"
DEPEND="${RDEPEND}
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
	dev-util/gdbus-codegen
	dev-util/gtk-doc-am
	test? (
		>=dev-python/twisted-16
		|| (
			net-analyzer/netcat
			net-analyzer/netcat6 ) )
	!udev? ( >=dev-libs/libgcrypt-1.2.2:0 )
"
# libgcrypt.m4, provided by libgcrypt, needed for eautoreconf, bug #399043
# test dependencies needed per https://bugzilla.gnome.org/700162

PATCHES=(
	"${FILESDIR}"/${PN}-1.30.2-sysmacros.patch #580234
	"${FILESDIR}"/rollup #599482
	# from gnome-3-30 branch, fixes RPATH of libgvfsdaemon.so
	"${FILESDIR}"/${PN}-1.38.3-gvfsdaemon-rpath.patch
)

src_configure() {
	local emesonargs=(
		-D gcr=true
		-D systemduserunitdir=$(usex systemd "$(systemd_get_userunitdir)" no)
		-D afp=$(usex afp true false)
		-D archive=$(usex archive true false)
		-D bluray=$(usex bluray true false)
		-D cdda=$(usex cdda true false)
		-D fuse=$(usex fuse true false)
		-D keyring=$(usex gnome-keyring true false)
		-D goa=$(usex gnome-online-accounts true false)
		-D google=$(usex google true false)
		-D gphoto2=$(usex gphoto2 true false)
		-D http=$(usex http true false)
		-D afc=$(usex ios true false)
		-D mtp=$(usex mtp true false)
		-D libusb=$(usex mtp true false)
		-D nfs=$(usex nfs true false)
		-D admin=$(usex policykit true false)
		-D smb=$(usex samba true false)
		-D gudev=$(usex udev true false)
		-D udisks2=$(usex udisks true false)
		-D dnssd=$(usex zeroconf true false)
	)
	if use elogind; then
		emesonargs+=(
			-D tmpfilesdir=no
		)
	fi
	if use elogind or use systemd; then
		emesonargs+=(
			-D logind=true
		)
	else
		emesonargs+=(
			-D logind=false
		)
	fi
	meson_src_configure
}
