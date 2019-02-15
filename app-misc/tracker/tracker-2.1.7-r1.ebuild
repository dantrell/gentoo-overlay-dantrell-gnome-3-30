# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_4,3_5,3_6,3_7} )

inherit bash-completion-r1 gnome2 linux-info python-any-r1 meson vala

DESCRIPTION="A tagging metadata database, search tool and indexer"
HOMEPAGE="https://wiki.gnome.org/Projects/Tracker"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0/100"
KEYWORDS=""

IUSE="elibc_glibc icu kernel_linux networkmanager stemmer systemd test upower"

# According to NEWS, introspection is non-optional
# glibc-2.12 needed for SCHED_IDLE (see bug #385003)
# sqlite-3.9.0 for FTS5 support
# seccomp is automagic, though we want to use it whenever possible (linux)
RDEPEND="
	>=dev-db/sqlite-3.8.3:=
	>=dev-libs/glib-2.58.0:2
	>=dev-libs/gobject-introspection-1.0:=
	icu? ( >=dev-libs/icu-4.8.1.1:= )
	!icu? ( dev-libs/libunistring )
	>=dev-libs/json-glib-1.0
	>=dev-libs/libxml2-2.6
	>=net-libs/libsoup-2.40:2.4
	>sys-apps/dbus-1.3.1

	elibc_glibc? ( >=sys-libs/glibc-2.12 )
	kernel_linux? ( >=sys-libs/libseccomp-2.0.0 )
	networkmanager? ( >=net-misc/networkmanager-0.8:= )
	stemmer? ( dev-libs/snowball-stemmer )
	systemd? ( sys-apps/systemd )
	upower? ( 
		>=sys-power/upower-0.9:=
		app-misc/tracker-miners[upower]
	)
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	$(vala_depend)
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.8
	>=dev-util/intltool-0.40.0
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	test? (
		>=dev-libs/dbus-glib-0.82-r1
		>=sys-apps/dbus-1.3.1[X] )
"
PDEPEND=""

PATCHES=(
	"${FILESDIR}"/${PN}-2.1.7-test-fix.patch # https://gitlab.gnome.org/GNOME/tracker/merge_requests/59
	"${FILESDIR}"/${PN}-2.1.7-prevent-stack-smashing.patch
	"${FILESDIR}"/${PN}-2.1.7-fix-library-symlinks.patch
)

function inotify_enabled() {
	if linux_config_exists; then
		if ! linux_chkconfig_present INOTIFY_USER; then
			ewarn "You should enable the INOTIFY support in your kernel."
			ewarn "Check the 'Inotify support for userland' under the 'File systems'"
			ewarn "option. It is marked as CONFIG_INOTIFY_USER in the config"
			die 'missing CONFIG_INOTIFY'
		fi
	else
		einfo "Could not check for INOTIFY support in your kernel."
	fi
}

pkg_setup() {
	linux-info_pkg_setup
	inotify_enabled

	python-any-r1_pkg_setup
}

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-Dbash_completion="$(get_bashcompdir)"
		-Ddocs=true
		-Dfts=true
		-Dfunctional_tests=false
		-Dnetwork_manager=$(usex networkmanager yes no)
		-Dstemmer=$(usex stemmer yes no)
		-Dsystemd_user_services=$(usex systemd yes no)
	)
	if use icu; then
		emesonargs+=(-Dunicode_support=icu)
	else
		emesonargs+=(-Dunicode_support=unistring)
	fi
	meson_src_configure
}
