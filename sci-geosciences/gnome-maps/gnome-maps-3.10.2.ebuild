# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"

inherit eutils gnome2

DESCRIPTION="A map application for GNOME"
HOMEPAGE="https://wiki.gnome.org/Design/Apps/Maps"

LICENSE="GPL-2+ LGPL-2+ MIT CC-BY-3.0 CC-BY-SA-3.0"
SLOT="0"
IUSE=""
KEYWORDS="~amd64"

RDEPEND="
	>=app-misc/geoclue-1.99.3
	>=dev-libs/gjs-1.38
	dev-libs/gobject-introspection
	>=dev-libs/glib-2.38:2
	media-libs/clutter-gtk:1.0[introspection]
	media-libs/clutter:1.0[introspection]
	media-libs/cogl:1.0[introspection]
	media-libs/libchamplain:0.12[introspection]
	net-libs/libsoup:2.4[introspection]
	sci-geosciences/geocode-glib[introspection]
	x11-libs/gdk-pixbuf:2[introspection]
	>=x11-libs/gtk+-3.10:3[introspection]
"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	virtual/pkgconfig
"

src_prepare() {
	# FIXME: autogenerated, should not be in tarball at all
	rm "${S}"/src/path.js || die

	gnome2_src_prepare
}
