# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
VALA_MIN_API_VERSION="0.18"
VALA_USE_DEPEND="vapigen"

inherit bash-completion-r1 check-reqs eutils user systemd base udev vala
if [[ ${PV} = 9999 ]]; then
	GCONF_DEBUG="no"
	inherit gnome2-live # need all the hacks from gnome2-live_src_prepare
fi

DESCRIPTION="System service to accurately color manage input and output devices"
HOMEPAGE="http://www.freedesktop.org/software/colord/"
if [[ ${PV} = 9999 ]]; then
	EGIT_REPO_URI="git://gitorious.org/colord/master.git"
else
	SRC_URI="http://www.freedesktop.org/software/colord/releases/${P}.tar.xz"
fi

LICENSE="GPL-2+"
SLOT="0/1" # subslot = libcolord soname version
IUSE="examples extra-print-profiles +gusb +introspection scanner systemd +udev vala"
REQUIRED_USE="
	gusb? ( udev )
	scanner? ( udev )
	vala? ( introspection )
"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
	IUSE="${IUSE} doc"
else
	KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
fi

COMMON_DEPEND="
	dev-db/sqlite:3=
	>=dev-libs/glib-2.32.0:2
	>=media-libs/lcms-2.5:2=
	>=sys-auth/polkit-0.103
	gusb? ( >=dev-libs/libgusb-0.1.1[introspection?] )
	introspection? ( >=dev-libs/gobject-introspection-0.9.8 )
	scanner? ( media-gfx/sane-backends )
	systemd? ( >=sys-apps/systemd-44 )
	udev? ( virtual/udev:=[gudev] )"
RDEPEND="${COMMON_DEPEND}
	!media-gfx/shared-color-profiles"
DEPEND="${COMMON_DEPEND}
	dev-libs/libxslt
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.35
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	extra-print-profiles? ( media-gfx/argyllcms )
	vala? ( $(vala_depend) )
"
if [[ ${PV} =~ 9999 ]]; then
	# Needed for generating man pages, not needed for tarballs
	DEPEND="${DEPEND}
		app-text/docbook-sgml-utils
		doc? (
			app-text/docbook-xml-dtd:4.1.2
			>=dev-util/gtk-doc-1.9 )"
fi

# FIXME: needs pre-installed dbus service files
RESTRICT="test"

# According to upstream comment in colord.spec.in, building the extra print
# profiles requires >=4G of memory
CHECKREQS_MEMORY="4G"

pkg_pretend() {
	use extra-print-profiles && check-reqs_pkg_pretend
}

pkg_setup() {
	use extra-print-profiles && check-reqs_pkg_setup
	enewgroup colord
	enewuser colord -1 -1 /var/lib/colord colord
}

src_prepare() {
	use vala && vala_src_prepare
}

src_configure() {
	local myconf=""
	[[ ${PV} = 9999 ]] && myconf="${myconf} $(use_enable doc gtk-doc)"
	# Reverse tools require gusb
	# bash-completion test does not work on gentoo
	econf \
		--disable-bash-completion \
		--disable-examples \
		--disable-gtk-doc \
		--disable-static \
		--disable-volume-search \
		--enable-polkit \
		--with-daemon-user=colord \
		--localstatedir="${EPREFIX}"/var \
		$(use_enable extra-print-profiles print-profiles) \
		$(usex extra-print-profiles COLPROF="$(type -P argyll-colprof)" "") \
		$(use_enable gusb) \
		$(use_enable gusb reverse) \
		$(use_enable introspection) \
		$(use_enable scanner sane) \
		$(use_enable systemd systemd-login) \
		$(use_enable udev gudev) \
		--with-udevrulesdir="$(udev_get_udevdir)"/rules.d \
		$(use_enable vala) \
		"$(systemd_with_unitdir)" \
		${myconf}

	if [[ ${PV} = 9999 ]]; then
		# parallel make fails in doc/api
		use doc && MAKEOPTS="${MAKEOPTS} -j1"
	fi
}

src_install() {
	DOCS=(AUTHORS ChangeLog MAINTAINERS NEWS README TODO)
	default

	newbashcomp data/colormgr colormgr
	rm -vr "${ED}etc/bash_completion.d"

	# Ensure config and profile directories exist and /var/lib/colord/*
	# is writable by colord user
	keepdir /var/lib/color{,d}/icc
	fowners colord:colord /var/lib/colord{,/icc}

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*.c
	fi

	prune_libtool_files --modules
}
