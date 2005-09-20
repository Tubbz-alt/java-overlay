# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_PN="${PN/-bin/}"
MY_PV="${PV/_beta/b}" # TODO do some magic with parameter substitution
MY_P="${MY_PN}-${MY_PV}"
DESCRIPTION=""
HOMEPAGE=""
SRC_URI="mirror://gentoo/${MY_P}.tar.gz"

LICENSE="INRIA"
SLOT="2"
KEYWORDS="~x86"
IUSE=""

RDEPEND="virtual/jre"

S="${WORKDIR}/${MY_PN}"

src_install() {
	java-pkg_dojar lib/${MY_PN}.jar
	dodoc ANNOUNCE README
}
