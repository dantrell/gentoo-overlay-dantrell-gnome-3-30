# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit bash-completion-r1 gnome2 meson

DESCRIPTION="GNOME's main interface to configure various aspects of the desktop"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-control-center/"

LICENSE="GPL-2+"
SLOT="2"
KEYWORDS="*"

IUSE="+bluetooth +colord +cups doc elogind +gnome-online-accounts +ibus input_devices_wacom kerberos libinput networkmanager +share systemd thunderbolt v4l vanilla-datetime vanilla-hostname wayland"
REQUIRED_USE="
	?? ( elogind systemd )
	wayland? ( || ( elogind systemd ) )
"

# False positives caused by nested configure scripts
QA_CONFIGURE_OPTIONS=".*"

COMMON_DEPEND="
	>=dev-libs/glib-2.44.0:2[dbus]
	>=x11-libs/gdk-pixbuf-2.23.0:2
	>=x11-libs/gtk+-3.22.0:3[X,wayland?]
	>=gnome-base/gsettings-desktop-schemas-3.21.4
	>=gnome-base/gnome-desktop-3.27.90:3=
	>=gnome-base/gnome-settings-daemon-3.25.90[colord(+),policykit]
	>=x11-misc/colord-0.1.34:0=

	>=dev-libs/libpwquality-1.2.2
	dev-libs/libxml2:2
	gnome-base/libgtop:2=
	media-libs/fontconfig
	>=sys-apps/accountsservice-0.6.39

	>=media-libs/libcanberra-0.13[gtk3]
	>=media-sound/pulseaudio-2[glib]
	>=sys-auth/polkit-0.97
	>=sys-power/upower-0.99.6:=

	virtual/libgudev
	x11-apps/xmodmap
	x11-libs/cairo
	x11-libs/libX11
	x11-libs/libXxf86misc
	>=x11-libs/libXi-1.2

	bluetooth? ( >=net-wireless/gnome-bluetooth-3.18.2:= )
	colord? (
		net-libs/libsoup:2.4
		>=x11-misc/colord-0.1.34:0=
		>=x11-libs/colord-gtk-0.1.24 )
	cups? (
		>=net-print/cups-1.7[dbus]
		>=net-fs/samba-4.0.0[client]
	)
	gnome-online-accounts? (
		>=media-libs/grilo-0.3.0:0.3=
		>=net-libs/gnome-online-accounts-3.21.5:= )
	ibus? ( >=app-i18n/ibus-1.5.2 )
	kerberos? ( app-crypt/mit-krb5 )
	networkmanager? (
		>=gnome-extra/nm-applet-1.2.0
		>=net-misc/networkmanager-1.10.0:=[modemmanager]
		>=net-misc/modemmanager-0.7.990 )
	v4l? (
		media-libs/clutter-gtk:1.0[gtk]
		>=media-video/cheese-3.5.91 )
	input_devices_wacom? (
		>=dev-libs/libwacom-0.7
		>=media-libs/clutter-1.11.3:1.0[gtk]
		media-libs/clutter-gtk:1.0[gtk]
		>=x11-libs/libXi-1.2 )
"
# <gnome-color-manager-3.1.2 has file collisions with g-c-c-3.1.x
# libgnomekbd needed only for gkbd-keyboard-display tool
#
# mouse panel needs a concrete set of X11 drivers at runtime, bug #580474
# Also we need newer driver versions to allow wacom and libinput drivers to
# not collide
#
# system-config-printer provides org.fedoraproject.Config.Printing service and interface
# cups-pk-helper provides org.opensuse.cupspkhelper.mechanism.all-edit policykit helper policy
RDEPEND="${COMMON_DEPEND}
	x11-themes/adwaita-icon-theme
	colord? ( >=gnome-extra/gnome-color-manager-3.28.0 )
	cups? (
		app-admin/system-config-printer
		net-print/cups-pk-helper )
	input_devices_wacom? ( gnome-base/gnome-settings-daemon[input_devices_wacom] )
	ibus? ( >=gnome-base/libgnomekbd-3 )
	wayland? ( libinput? ( dev-libs/libinput ) )
	!wayland? (
		libinput? ( >=x11-drivers/xf86-input-libinput-0.19.0 )
		input_devices_wacom? ( >=x11-drivers/xf86-input-wacom-0.33.0 ) )

	!<gnome-base/gdm-2.91.94
	!<gnome-extra/gnome-color-manager-3.1.2
	!gnome-extra/gnome-media[pulseaudio]
	!<gnome-extra/gnome-media-2.32.0-r300
	!<net-wireless/gnome-bluetooth-3.3.2

	elogind? ( sys-auth/elogind )
	systemd? ( >=sys-apps/systemd-186:0= )
	!systemd? ( app-admin/openrc-settingsd )
"
# PDEPEND to avoid circular dependency
PDEPEND=">=gnome-base/gnome-session-2.91.6-r1"

DEPEND="${COMMON_DEPEND}
	x11-base/xorg-proto

	dev-libs/libxml2:2
	dev-libs/libxslt
	>=dev-util/intltool-0.40.1
	>=sys-devel/gettext-0.17
	virtual/pkgconfig

	gnome-base/gnome-common
"

src_prepare() {
	# Make some panels and dependencies optional
	# https://bugzilla.gnome.org/686840, 697478, 700145
	eapply "${FILESDIR}"/${PN}-3.30.2-optional.patch

	# From GNOME:
	# 	https://bugzilla.gnome.org/show_bug.cgi?id=774324
	# 	https://bugzilla.gnome.org/show_bug.cgi?id=780544
	eapply "${FILESDIR}"/${PN}-3.24.2-fix-without-gdkwayland.patch

	if ! use vanilla-datetime; then
		# From Funtoo:
		# 	https://bugs.funtoo.org/browse/FL-1389
		eapply "${FILESDIR}"/${PN}-3.30.0-disable-automatic-datetime-and-timezone-options.patch
	fi

	if ! use vanilla-hostname; then
		# From Funtoo:
		# 	https://bugs.funtoo.org/browse/FL-1391
		eapply "${FILESDIR}"/${PN}-3.30.0-disable-changing-hostname.patch
	fi

	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D bluetooth=$(usex bluetooth true false)
		-D cheese=$(usex v4l true false)
		-D color=$(usex colord true false)
		-D cups=$(usex cups true false)
		-D documentation=$(usex doc true false)
		-D goa=$(usex gnome-online-accounts true false)
		-D ibus=$(usex ibus true false)
		-D krb=$(usex kerberos true false)
		-D networkmanager=$(usex networkmanager true false)
		-D sharing=$(usex share true false)
		-D thunderbolt=$(usex thunderbolt true false)
		-D tracing=false
		-D wacom=$(usex input_devices_wacom true false)
		-D wayland=$(usex wayland true false)
	)
	meson_src_configure
}
