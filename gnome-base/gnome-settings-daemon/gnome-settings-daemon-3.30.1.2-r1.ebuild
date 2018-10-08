# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_4,3_5,3_6,3_7} )

inherit gnome2 meson python-any-r1 systemd udev virtualx

DESCRIPTION="Gnome Settings Daemon"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-settings-daemon"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="+colord +cups debug elogind input_devices_wacom networkmanager policykit smartcard systemd test +udev vanilla-inactivity wayland"
REQUIRED_USE="
	?? ( elogind systemd )
	input_devices_wacom? ( udev )
	smartcard? ( udev )
	wayland? ( udev )
"

COMMON_DEPEND="
	>=dev-libs/glib-2.44.0:2[dbus]
	>=x11-libs/gtk+-3.15.3:3[X,wayland?]
	>=gnome-base/gnome-desktop-3.11.1:3=
	>=gnome-base/gsettings-desktop-schemas-3.23.3
	>=gnome-base/librsvg-2.36.2:2
	media-fonts/cantarell
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/libcanberra[gtk3]
	>=media-sound/pulseaudio-2
	>=sys-power/upower-0.99:=
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	>=x11-libs/libnotify-0.7.3:=
	x11-libs/libX11
	x11-libs/libxkbfile
	x11-libs/libXi
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXtst
	x11-libs/libXxf86misc
	x11-misc/xkeyboard-config

	>=app-misc/geoclue-2.3.1:2.0
	>=dev-libs/libgweather-3.9.5:2=
	>=sci-geosciences/geocode-glib-3.10
	>=sys-auth/polkit-0.103

	colord? (
		>=media-libs/lcms-2.2:2
		>=x11-misc/colord-1.0.2:= )
	cups? ( >=net-print/cups-1.4[dbus] )
	input_devices_wacom? (
		>=dev-libs/libwacom-0.7
		>=x11-libs/pango-1.20
		x11-drivers/xf86-input-wacom
		virtual/libgudev:= )
	networkmanager? ( >=net-misc/networkmanager-1.0:= )
	smartcard? ( >=dev-libs/nss-3.11.2 )
	udev? ( virtual/libgudev:= )
	wayland? ( dev-libs/wayland )
"
# Themes needed by g-s-d, gnome-shell, gtk+:3 apps to work properly
# <gnome-color-manager-3.1.1 has file collisions with g-s-d-3.1.x
# <gnome-power-manager-3.1.3 has file collisions with g-s-d-3.1.x
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	!<gnome-base/gnome-control-center-2.22
	!<gnome-extra/gnome-color-manager-3.1.1
	!<gnome-extra/gnome-power-manager-3.1.3
	!<gnome-base/gnome-session-3.27.90

	elogind? ( sys-auth/elogind )
	systemd? ( >=sys-apps/systemd-186:0= )
"
# xproto-7.0.15 needed for power plugin
DEPEND="${COMMON_DEPEND}
	cups? ( sys-apps/sed )
	test? (
		${PYTHON_DEPS}
		$(python_gen_any_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
		$(python_gen_any_dep 'dev-python/dbusmock[${PYTHON_USEDEP}]')
		gnome-base/gnome-session )
	dev-libs/libxml2:2
	sys-devel/gettext
	>=dev-util/intltool-0.40
	virtual/pkgconfig
	x11-base/xorg-proto
"

python_check_deps() {
	if use test; then
		has_version "dev-python/pygobject:3[${PYTHON_USEDEP}]" &&
		has_version "dev-python/dbusmock[${PYTHON_USEDEP}]"
	fi
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	# Make colord, networkmanager, udev and wacom optional
	eapply "${FILESDIR}"/${PN}-3.30.1.1-optional.patch
	# Fix build when Wayland is disabled
	eapply "${FILESDIR}"/${PN}-3.24.3-fix-without-gdkwayland.patch

	if ! use vanilla-inactivity; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/gnome-settings-daemon/commit/2fdb48fa3333638cee889b8bb80dc1d2b65aaa4a
		eapply "${FILESDIR}"/${PN}-3.30.1.2-power-dont-default-to-suspend-after-20-minutes-of-inactivity.patch
	fi

	# From Ben Wolsieffer:
	# 	https://bugzilla.gnome.org/show_bug.cgi?id=734964
	eapply "${FILESDIR}"/${PN}-3.30.1.2-optionally-allow-suspending-with-multiple-monitors-on-lid-close.patch

	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D udev_dir="$(get_udevdir)"/rules.d
		-D alsa=true
		-D gudev=$(usex udev true false)
		-D color=$(usex colord true false)
		-D cups=$(usex cups true false)
		-D network_manager=$(usex networkmanager true false)
		-D rfkill=true
		-D smartcard=$(usex smartcard true false)
		-D wacom=$(usex input_devices_wacom true false)
		-D wayland=$(usex wayland true false)
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test
}

pkg_postinst() {
	gnome2_pkg_postinst

	if use systemd && ! systemd_is_booted; then
		ewarn "${PN} needs Systemd to be *running* for working"
		ewarn "properly. Please follow the this guide to migrate:"
		ewarn "https://wiki.gentoo.org/wiki/Systemd"
	fi

	if ! use systemd; then
		ewarn "You have emerged ${PN} without systemd,"
		ewarn "if you experience any issues please use the support thread:"
		ewarn "https://forums.gentoo.org/viewtopic-t-1082226.html"
	fi
}
