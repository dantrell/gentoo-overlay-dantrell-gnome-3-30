# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome2 meson multilib pax-utils python-r1 systemd

DESCRIPTION="Provides core UI functions for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeShell https://gitlab.gnome.org/GNOME/gnome-shell"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="+bluetooth browser-extension deprecated-background doc elogind +networkmanager nsplugin systemd vanilla-gc vanilla-motd vanilla-screen wayland"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	?? ( elogind systemd )
"

# libXfixes-5.0 needed for pointer barriers and #include <X11/extensions/Xfixes.h>
COMMON_DEPEND="
	>=app-accessibility/at-spi2-atk-2.5.3
	>=dev-libs/atk-2[introspection]
	>=app-crypt/gcr-3.7.5:0=[introspection]
	>=dev-libs/glib-2.45.3:2[dbus]
	>=dev-libs/gjs-1.47.0
	>=dev-libs/gobject-introspection-1.49.1:=
	dev-libs/libical:=
	>=x11-libs/gtk+-3.15.0:3[introspection]
	>=dev-libs/libcroco-0.6.8:0.6
	>=gnome-base/gnome-desktop-3.7.90:3=[introspection]
	>=gnome-base/gsettings-desktop-schemas-3.21.3
	>=gnome-extra/evolution-data-server-3.17.2:=
	>=media-libs/gstreamer-0.11.92:1.0
	>=net-im/telepathy-logger-0.2.4[introspection]
	>=net-libs/telepathy-glib-0.19[introspection]
	>=sys-auth/polkit-0.100[introspection]
	>=x11-libs/libXfixes-5.0
	x11-libs/libXtst
	>=x11-wm/mutter-3.30.1[deprecated-background=,introspection]
	>=x11-libs/startup-notification-0.11

	${PYTHON_DEPS}
	dev-python/pygobject:3[${PYTHON_USEDEP}]

	>=app-i18n/ibus-1.4.99[dconf(+),gtk,introspection]
	dev-libs/dbus-glib
	dev-libs/libxml2:2
	media-libs/libcanberra[gtk3]
	wayland? ( media-libs/mesa )
	!wayland? ( media-libs/mesa[X(+)] )
	>=media-sound/pulseaudio-2
	>=net-libs/libsoup-2.40:2.4[introspection]
	x11-libs/libX11
	x11-libs/gdk-pixbuf:2[introspection]

	x11-apps/mesa-progs

	bluetooth? ( >=net-wireless/gnome-bluetooth-3.9[introspection] )
	doc? ( >=dev-build/gtk-doc-am-1.17 )
	networkmanager? (
		app-crypt/libsecret
		>=gnome-extra/nm-applet-0.9.8
		>=net-misc/networkmanager-0.9.8:=[introspection] )
	nsplugin? ( >=dev-libs/json-glib-0.13.2 )
"
# Runtime-only deps are probably incomplete and approximate.
# Introspection deps generated using:
#  grep -roe "imports.gi.*" gnome-shell-* | cut -f2 -d: | sort | uniq
# Each block:
# 1. Introspection stuff needed via imports.gi.*
# 2. gnome-session is needed for gnome-session-quit
# 3. Control shell settings
# 4. Systemd optional for suspending support
# 5. xdg-utils needed for xdg-open, used by extension tool
# 6. adwaita-icon-theme and dejavu font neeed for various icons & arrows
# 7. mobile-broadband-provider-info, timezone-data for shell-mobile-providers.c
# 8. IBus is needed for nls integration
RDEPEND="${COMMON_DEPEND}
	app-accessibility/at-spi2-core:2[introspection]
	>=app-accessibility/caribou-0.4.8
	dev-libs/libgweather:2[introspection]
	>=sys-apps/accountsservice-0.6.14[introspection]
	>=sys-power/upower-0.99:=[introspection]
	x11-libs/pango[introspection]
	gnome-base/librsvg:2[introspection]

	>=gnome-base/gnome-session-2.91.91
	>=gnome-base/gnome-settings-daemon-3.8.3

	elogind? ( sys-auth/elogind )
	systemd? ( >=sys-apps/systemd-186:0= )

	x11-misc/xdg-utils

	media-fonts/dejavu
	>=x11-themes/adwaita-icon-theme-3.19.90

	networkmanager? (
		net-misc/mobile-broadband-provider-info
		sys-libs/timezone-data )
"
# avoid circular dependency, see bug #546134
PDEPEND="
	>=gnome-base/gdm-3.5[introspection(+)]
	>=gnome-base/gnome-control-center-3.8.3[bluetooth(+)?,networkmanager(+)?]
	browser-extension? ( gnome-extra/gnome-browser-connector )
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libxslt
	dev-lang/sassc
	>=dev-util/gdbus-codegen-2.45.3
	gnome-base/gnome-common
	dev-build/autoconf-archive
	>=sys-devel/gettext-0.19.6
	virtual/pkgconfig
"

src_prepare() {
	if use deprecated-background; then
		eapply "${FILESDIR}"/${PN}-3.26.1-restore-deprecated-background-code.patch
	fi

	if ! use vanilla-gc; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/64
		eapply "${FILESDIR}"/${PN}-3.14.4-force-garbage-collection.patch
	fi

	if ! use vanilla-motd; then
		eapply "${FILESDIR}"/${PN}-3.28.0-improve-motd-handling.patch
	fi

	if ! use vanilla-screen; then
		eapply "${FILESDIR}"/${PN}-3.28.0-improve-screen-blanking.patch
	fi

	# Change favorites defaults, bug #479918
	eapply "${FILESDIR}"/${PN}-3.22.0-defaults.patch

	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D browser_plugin=$(usex nsplugin true false)
		-D gtk_doc=$(usex doc true false)
		-D man=true
		-D networkmanager=$(usex networkmanager true false)
		-D systemd=$(usex systemd true false)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	python_replicate_script "${ED}/usr/bin/gnome-shell-extension-tool"
	python_replicate_script "${ED}/usr/bin/gnome-shell-perf-tool"

	# Required for gnome-shell on hardened/PaX, bug #398941
	# Future-proof for >=spidermonkey-1.8.7 following polkit's example
	if has_version '<dev-lang/spidermonkey-1.8.7'; then
		pax-mark mr "${ED}usr/bin/gnome-shell"{,-extension-prefs}
	elif has_version '>=dev-lang/spidermonkey-1.8.7[jit]'; then
		pax-mark m "${ED}usr/bin/gnome-shell"{,-extension-prefs}
	# Required for gnome-shell on hardened/PaX #457146 and #457194
	# PaX EMUTRAMP need to be on
	elif has_version '>=dev-libs/libffi-3.0.13[pax_kernel]'; then
		pax-mark E "${ED}usr/bin/gnome-shell"{,-extension-prefs}
	else
		pax-mark m "${ED}usr/bin/gnome-shell"{,-extension-prefs}
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postinst() {
	gnome2_pkg_postinst
	gnome2_schemas_update

	if ! has_version 'media-libs/gst-plugins-good:1.0' || \
	   ! has_version 'media-plugins/gst-plugins-vpx:1.0'; then
		ewarn "To make use of GNOME Shell's built-in screen recording utility,"
		ewarn "you need to either install media-libs/gst-plugins-good:1.0"
		ewarn "and media-plugins/gst-plugins-vpx:1.0, or use dconf-editor to change"
		ewarn "apps.gnome-shell.recorder/pipeline to what you want to use."
	fi

	if ! has_version "media-libs/mesa[llvm]"; then
		elog "llvmpipe is used as fallback when no 3D acceleration"
		elog "is available. You will need to enable llvm USE for"
		elog "media-libs/mesa if you do not have hardware 3D setup."
	fi

	# https://bugs.gentoo.org/563084
	if has_version "x11-drivers/nvidia-drivers[-kms]"; then
		ewarn "You will need to enable kms support in x11-drivers/nvidia-drivers,"
		ewarn "otherwise Gnome will fail to start"
	fi

	if use systemd && [[ ! -d /run/systemd/system ]]; then
		ewarn "You have installed GNOME Shell *with* systemd support"
		ewarn "but the system was not booted using systemd."
		ewarn "To correct this, reference: https://wiki.gentoo.org/wiki/Systemd"
	fi

	if ! use systemd; then
		ewarn "You have installed GNOME Shell *without* systemd support."
		ewarn "To report issues, see: https://github.com/dantrell/gentoo-project-gnome-without-systemd/blob/master/GOVERNANCE.md#bugs-and-other-issues"
	fi
}
