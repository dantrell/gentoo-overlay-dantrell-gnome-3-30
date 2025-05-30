# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools flag-o-matic gnome2 readme.gentoo-r1

DESCRIPTION="Archive manager for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/FileRoller"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

IUSE="libnotify nautilus"

# gdk-pixbuf used extensively in the source
# cairo used in eggtreemultidnd.c
# pango used in fr-window
RDEPEND="
	>=app-arch/libarchive-3:=
	>=dev-libs/glib-2.36:2
	>=dev-libs/json-glib-0.14
	>=x11-libs/gtk+-3.13.2:3
	sys-apps/file
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/pango
	libnotify? ( >=x11-libs/libnotify-0.4.3:= )
	nautilus? ( >=gnome-base/nautilus-3[-vanilla-menu-compress] )
"
# libxml2 required for glib-compile-resources
DEPEND="${RDEPEND}
	dev-libs/libxml2:2
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
${PN} is a frontend for several archiving utilities. If you want a
particular archive format support, see ${HOMEPAGE}
and install the relevant package. For example:
7-zip   - app-arch/p7zip
ace     - app-arch/unace
arj     - app-arch/arj
cpio    - app-arch/cpio
deb     - app-arch/dpkg
iso     - app-cdr/cdrtools
jar,zip - app-arch/zip and app-arch/unzip
lha     - app-arch/lha
lzop    - app-arch/lzop
lz4     - app-arch/lz4
rar     - app-arch/unrar or app-arch/unar
rpm     - app-arch/rpm
unstuff - app-arch/stuffit
zoo     - app-arch/zoo"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/file-roller/-/commit/80ce23d399e3911cc44447ca2e13e60b4356c14a
	eapply "${FILESDIR}"/${PN}-3.30.1-support-autotools.patch

	if use nautilus; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/file-roller/-/commit/a4b806fffe8824c8eb5fb18ee404d879902529ec
		# 	https://gitlab.gnome.org/GNOME/file-roller/-/commit/fad2372ccbbfd40013b4225002f4a737d67928bc
		# 	https://gitlab.gnome.org/GNOME/file-roller/-/commit/aab1b7335c40b8b0e3d5a00cf8305dc53d48f3c8
		# 	https://gitlab.gnome.org/GNOME/file-roller/-/commit/366a5147bd097a877d85295a36fb062213355a36
		# 	https://gitlab.gnome.org/GNOME/file-roller/-/commit/da09ee41ca7c9b63082cf2a35ae19701c34adca7
		eapply -R "${FILESDIR}"/${PN}-3.25.1-use-unicode-in-translatable-strings.patch
		eapply -R "${FILESDIR}"/${PN}-3.23.92-nautilus-fileroller-remove-compress-support.patch
		eapply -R "${FILESDIR}"/${PN}-3.23.91-nautilus-fileroller-remove-mime-types-already-supported-by-nautilus.patch
		eapply -R "${FILESDIR}"/${PN}-3.23.91-revert-remove-nautilus-extension.patch
		eapply -R "${FILESDIR}"/${PN}-3.21.91-remove-nautilus-extension.patch
	fi

	# From GNOME (CVE-2020-11736):
	# 	https://gitlab.gnome.org/GNOME/file-roller/-/commit/45b2e76e25648961db621f898b4a9eb7c75ef4c0
	# 	https://gitlab.gnome.org/GNOME/file-roller/-/commit/8572946d3ebe25f392f110ee838ff5abc7a3e78e
	eapply "${FILESDIR}"/${PN}-3.32.5-libarchive-do-not-follow-external-links-when-extracting-files.patch
	eapply "${FILESDIR}"/${PN}-3.32.5-libarchive-overwrite-the-symbolic-link-as-well.patch

	# File providing Gentoo package names for various archivers
	cp -f "${FILESDIR}"/3.22-packages.match data/packages.match || die

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	# Work around -fno-common (GCC 10 default)
	append-flags -fcommon

	# --disable-debug because enabling it adds -O0 to CFLAGS
	gnome2_src_configure \
		--disable-run-in-place \
		--disable-static \
		--disable-debug \
		--enable-magic \
		--enable-libarchive \
		$(use_enable libnotify notification) \
		$(use_enable nautilus nautilus-actions) \
		--disable-packagekit
}

src_install() {
	gnome2_src_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	gnome2_pkg_postinst
	readme.gentoo_print_elog
}
