# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome2 python-single-r1 meson

DESCRIPTION="Customize advanced GNOME options"
HOMEPAGE="https://wiki.gnome.org/Apps/Tweaks"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="
	${PYTHON_DEPS}
	dev-libs/glib:2[dbus]
	$(python_gen_cond_dep '
		>=dev-python/pygobject-3.10.2:3[${PYTHON_USEDEP}]
	')
	>=gnome-base/gsettings-desktop-schemas-3.23.3
"
# g-s-d, gnome-desktop, gnome-shell etc. needed at runtime for the gsettings schemas
RDEPEND="${COMMON_DEPEND}
	>=gnome-base/gnome-desktop-3.6.0.1:3[introspection]
	>=x11-libs/gtk+-3.12:3[introspection]

	net-libs/libsoup:2.4[introspection]
	x11-libs/libnotify[introspection]

	>=gnome-base/gnome-settings-daemon-3
	>=gnome-base/gnome-shell-3.30
	>=gnome-base/nautilus-3
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.40.0
	virtual/pkgconfig
"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	# Add contents of Gentoo's cursor theme directory to cursor theme list
	eapply "${FILESDIR}"/${PN}-3.28.1-gentoo-cursor-themes.patch

	gnome2_src_prepare
}

src_install() {
	meson_src_install
	python_fix_shebang "${D}"usr/bin/"${PN}"
}
