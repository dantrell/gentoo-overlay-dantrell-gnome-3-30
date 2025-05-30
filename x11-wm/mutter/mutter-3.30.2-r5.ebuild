# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools gnome2 virtualx

DESCRIPTION="GNOME compositing window manager based on Clutter"
HOMEPAGE="https://gitlab.gnome.org/GNOME/mutter"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="ck debug deprecated-background elogind gles2 input_devices_wacom +introspection screencast systemd test udev +vanilla-mipmapping wayland"
REQUIRED_USE="
	?? ( ck elogind systemd )
	wayland? ( || ( elogind systemd ) )
"

RESTRICT="!test? ( test )"

# libXi-1.7.4 or newer needed per:
# https://bugzilla.gnome.org/show_bug.cgi?id=738944
COMMON_DEPEND="
	>=dev-libs/atk-2.5.3
	>=x11-libs/gdk-pixbuf-2:2
	>=dev-libs/json-glib-0.12.0
	>=x11-libs/pango-1.30[introspection?]
	>=x11-libs/cairo-1.14[X]
	>=x11-libs/gtk+-3.19.8:3[X,introspection?]
	>=dev-libs/glib-2.53.4:2[dbus]
	>=media-libs/libcanberra-0.26[gtk3]
	>=x11-libs/startup-notification-0.7
	>=x11-libs/libXcomposite-0.2
	>=gnome-base/gsettings-desktop-schemas-3.21.4[introspection?]
	gnome-base/gnome-desktop:3=
	>sys-power/upower-0.99:=

	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	>=x11-libs/libXcomposite-0.4
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	>=x11-libs/libXfixes-3
	>=x11-libs/libXi-1.7.4
	x11-libs/libXinerama
	>=x11-libs/libXrandr-1.5
	x11-libs/libXrender
	x11-libs/libxcb
	x11-libs/libxkbfile
	>=x11-libs/libxkbcommon-0.4.3[X]
	x11-misc/xkeyboard-config

	gnome-extra/zenity
	>=media-libs/mesa-17.2.0[X(+),egl(+),gles2?]

	gles2? ( media-libs/mesa[gles2] )
	input_devices_wacom? ( >=dev-libs/libwacom-0.13 )
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
	udev? ( >=dev-libs/libgudev-232:= )
	screencast? ( >=media-video/pipewire-0.2.2:0/0.2 )
	wayland? (
		>=dev-libs/libinput-1.4
		>=dev-libs/wayland-1.6.90
		>=dev-libs/wayland-protocols-1.9
		>=media-libs/mesa-10.3[egl(+),gbm(+),wayland]
		|| ( sys-auth/elogind sys-apps/systemd )
		>=dev-libs/libgudev-232:=
		>=virtual/libudev-136:=
		x11-base/xwayland
		x11-libs/libdrm:=
	)
"
DEPEND="${COMMON_DEPEND}
	>=sys-devel/gettext-0.19.6
	virtual/pkgconfig
	x11-base/xorg-proto
	test? ( app-text/docbook-xml-dtd:4.5 )
	wayland? ( >=sys-kernel/linux-headers-4.4 )
"
RDEPEND="${COMMON_DEPEND}
	!x11-misc/expocity
"

src_prepare() {
	# Disable building of noinst_PROGRAM for tests
	if ! use test; then
		sed -e '/^noinst_PROGRAMS/d' \
			-i cogl/tests/conform/Makefile.{am,in} || die
		sed -e '/noinst_PROGRAMS += testboxes/d' \
			-i src/Makefile-tests.am || die
		sed -e '/noinst_PROGRAMS/ s/testboxes$(EXEEXT)//' \
			-i src/Makefile.in || die
	fi

	if use elogind; then
		eapply "${FILESDIR}"/${PN}-3.28.2-support-elogind.patch
	fi

	if use deprecated-background; then
		eapply "${FILESDIR}"/${PN}-3.26.1-restore-deprecated-background-code.patch
	fi

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/89
	if ! use vanilla-mipmapping; then
		eapply "${FILESDIR}"/${PN}-3.24.4-metashapedtexture-disable-mipmapping-emulation.patch
	fi

	eapply "${FILESDIR}"/patches/r4/

	eapply "${FILESDIR}"/${PN}-3.24.4-eglmesaext-include.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/mutter/-/commit/6c5baf89ede6ea4e52724194003aae4f70427677
	# 	https://gitlab.gnome.org/GNOME/mutter/-/commit/5201d77b0bcc3d790f13bbdfb8e6cd08e53eec83
	eapply "${FILESDIR}"/${PN}-3.31.4-keybindings-limit-corner-move-to-current-monitor.patch
	eapply "${FILESDIR}"/${PN}-3.37.2-keybindings-use-current-monitor-for-move-to-center.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/mutter/-/commit/3df4348f236f6bd8e2f37e633885dfde841fc988
	# 	https://gitlab.gnome.org/GNOME/mutter/-/commit/033f0d11bfd87f82cbd3ffc56b97574bb3ffb691
	# 	https://gitlab.gnome.org/GNOME/mutter/-/commit/64ced1632e277e4fc0b1f4de3f5bf229c6cf885b
	eapply "${FILESDIR}"/${PN}-3.34.2-window-reset-tile-monitor-number-when-untiling.patch
	eapply "${FILESDIR}"/${PN}-3.37.2-window-set-fall-back-tile-monitor-if-not-set.patch
	eapply "${FILESDIR}"/${PN}-3.38.2-window-dont-override-tile-monitor.patch

	eautoreconf
	gnome2_src_prepare

	# Leave the damn CFLAGS alone
	sed -e 's/$CFLAGS -g/$CFLAGS /' \
		-i clutter/configure || die
	sed -e 's/$CFLAGS -g -O0/$CFLAGS /' \
		-i cogl/configure || die
	sed -e 's/$CFLAGS -g -O/$CFLAGS /' \
		-i configure || die
}

src_configure() {
	# Prefer gl driver by default
	# GLX is forced by mutter but optional in clutter
	# xlib-egl-platform required by mutter x11 backend
	# native backend without wayland is useless
	gnome2_src_configure \
		--disable-static \
		--enable-compile-warnings=minimum \
		--enable-gl \
		--enable-glx \
		--enable-sm \
		--enable-startup-notification \
		--enable-verbose-mode \
		--enable-xlib-egl-platform \
		--with-default-driver=gl \
		--with-libcanberra \
		$(usex debug --enable-debug=yes "") \
		$(use_enable gles2) \
		$(use_enable gles2 cogl-gles2) \
		$(use_enable introspection) \
		$(use_enable screencast remote-desktop) \
		$(use_enable wayland) \
		$(use_enable wayland egl-device) \
		$(use_enable wayland kms-egl-platform) \
		$(use_enable wayland native-backend) \
		$(use_enable wayland wayland-egl-server) \
		$(use_with input_devices_wacom libwacom) \
		$(use_with udev gudev)
}

src_test() {
	virtx emake check
}
