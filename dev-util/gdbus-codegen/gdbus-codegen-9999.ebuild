# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME_ORG_MODULE="glib"
PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )
PYTHON_REQ_USE="xml"

inherit gnome.org distutils-r1
if [[ ${PV} = 9999 ]]; then
	inherit git-r3
fi

DESCRIPTION="GDBus code and documentation generator"
HOMEPAGE="http://www.gtk.org/"

if [[ ${PV} = 9999 ]]; then
	EGIT_REPO_URI="https://git.gnome.org/browse/${GNOME_ORG_MODULE}"
	SRC_URI=""
fi

LICENSE="LGPL-2+"
SLOT="0"

if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
fi

IUSE=""

RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}"

# To prevent circular dependencies with glib[test]
PDEPEND=">=dev-libs/glib-${PV}:2"

S="${WORKDIR}/glib-${PV}/gio/gdbus-2.0/codegen"

python_prepare_all() {
	PATCHES=(
		"${FILESDIR}/${PN}-2.54.2-sitedir.patch"
	)
	distutils-r1_python_prepare_all

	sed -e 's:@PYTHON@:python:' gdbus-codegen.in > gdbus-codegen || die
	cp "${FILESDIR}/setup.py-2.32.4" setup.py || die "cp failed"
	sed -e "s/@PV@/${PV}/" -i setup.py || die "sed setup.py failed"
}

src_test() {
	einfo "Skipping tests. This package is tested by dev-libs/glib"
	einfo "when merged with FEATURES=test"
}

python_install_all() {
	distutils-r1_python_install_all # no-op, but prevents QA warning
	doman "${WORKDIR}/glib-${PV}/docs/reference/gio/gdbus-codegen.1"
}
