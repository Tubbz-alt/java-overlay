# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg

DESCRIPTION="NetBeans ${PV} IDE for Java"

IUSE="debug doc"
HOMEPAGE="http://www.netbeans.org"

MAINTARBALL="netbeans-4_0-src-ide_sources.tar.bz2"
JAVADOCTARBALL="netbeans-4_0-docs-javadoc.tar.bz2"
BASELOCATION=" \
http://www.netbeans.org/download/4_0/fcs/200412081800/d5a0f13566068cb86e33a46ea130b207"

SRC_URI="${BASELOCATION}/${MAINTARBALL} \
		 doc? ( ${BASELOCATION}/${JAVADOCTARBALL} )
		 "

SLOT="4.0"

#When we have java-pkg_jar-from to everything only SPL should be needed here. 
LICENSE="SPL"
KEYWORDS="~x86"

#Bad tomcat versions <r2

DEPEND=">=virtual/jdk-1.4.2
		>=dev-java/ant-1.6.1
		>=dev-java/javahelp-bin-2.0.02-r1
		dev-java/jmi
		dev-java/mof
		=dev-java/xerces-2.6.2*
		=dev-java/commons-logging-1.0*
		=dev-java/jakarta-regexp-1.3*
		=dev-java/xalan-2*
		=dev-java/junit-3.8*
		dev-java/sac
		=dev-java/servletapi-2.2*
		=dev-java/servletapi-2.3*
		=dev-java/servletapi-2.4*
		dev-java/commons-el
		dev-java/jtidy
		=dev-java/jaxen-1.1*
		dev-java/saxpath
		~www-servers/tomcat-5.0.28
		dev-java/javamake-bin
		dev-java/jsr088
		dev-java/xml-commons
		dev-java/xml-commons-resolver
		"


RDEPEND="
		>=virtual/jre-1.4.2
		dev-java/commons-el
		=dev-java/servletapi-2.4*
		dev-java/sac
		dev-java/flute
		>=dev-java/javahelp-bin-2.0.02-r1
		~www-servers/tomcat-5.0.28
		"

S=${WORKDIR}/netbeans-src

BUILDDESTINATION="${S}/nbbuild/netbeans"

TOMCATSLOT="5"

RM="rm"

#jar replacements for Netbeans
COMMONS_LOGGING="commons-logging commons-logging.jar commons-logging-1.0.4.jar"
JH="javahelp-bin jh.jar jh-2.0_01.jar"
JSPAPI="servletapi-2.4 jsp-api.jar jsp-api-2.0.jar"
JSR="jsr088 jsr088.jar jsr88javax.jar"
JUNIT="junit junit.jar junit-3.8.1.jar"
SERVLET22="servletapi-2.2 servletapi-2.2.jar servlet-2.2.jar"
SERVLET23="servletapi-2.3 servletapi-2.3.jar servlet-2.3.jar"
SERVLET24="servletapi-2.4 servlet-api.jar servlet-api-2.4.jar"
XERCES="xerces-2 xercesImpl.jar xerces-2.6.2.jar"
JASPERCOMPILER="tomcat-${TOMCATSLOT}  jasper-compiler.jar jasper-compiler-5.0.28.jar"
JASPERRUNTIME="tomcat-${TOMCATSLOT}  jasper-runtime.jar jasper-runtime-5.0.28.jar"
XMLCOMMONS="xml-commons xml-apis.jar xml-commons-dom-ranges-1.0.b2.jar"

pkg_setup ()
{
	use debug && ${RM}="rm -v"
}

fix_manifest()
{
	sed "s%ext/${1}%$(java-pkg_getjar ${2} ${3})%" -i ${4}
}	
src_unpack () 
{
	unpack $MAINTARBALL

	if use doc; then
		mkdir javadoc
		cd javadoc
		unpack $JAVADOCTARBALL
		${RM} *.zip
	fi

	cd ${S}
#	epatch ${FILESDIR}/nbbuild.patch

	#removing tomcat
#	${RM} -fr tomcatint 

#	cd ${S}/nbbuild
#	cp ${FILESDIR}/user.build.properties . 

	#we have ant libs here so using the system libs	
	cd ${S}/ant/external/
	epatch ${FILESDIR}/antbuild.xml.patch
	mkdir lib; cd lib
	java-pkg_jar-from ant-tasks
	java-pkg_jar-from ant-core

	cd ${S}/core/external
	java-pkg_jar-from ${JH}
#	fix_manifest ${JH} javahelp-bin jh.jar ${S}/core/javahelp/manifest.mf
	
	cd ${S}/mdr/external/
	java-pkg_jar-from jmi
	java-pkg_jar-from mof

	cd ${S}/nbbuild/external
	java-pkg_jar-from javahelp-bin jhall.jar jhall-2.0_01.jar

	cd ${S}/libs/external/
	java-pkg_jar-from ${XERCES}	
	java-pkg_jar-from ${COMMONS_LOGGING}
	java-pkg_jar-from jakarta-regexp-1.3 regexp.jar	regexp-1.2.jar
	java-pkg_jar-from xalan xalan-jar xalan-2.5.2.jar
	java-pkg_jar-from ${XMLCOMMONS}

	cd ${S}/xml/external/
	java-pkg_jar-from sac 
	java-pkg_jar-from xerces-2 xercesImpl.jar xerces2.jar
	java-pkg_jar-from flute

	cd ${S}/httpserver/external/
	java-pkg_jar-from ${SERVLET22}
#	touch webserver.txt
#	jar -cf webserver.jar webserver.txt
#	java-pkg_jar-from tomcat-5

	cd ${S}/j2eeserver/external
	java-pkg_jar-from jsr088 jsr088 jsr088.jar jsr88javax.jar
		
	cd ${S}/java/external/
	java-pkg_jar-from javamake-bin javamake.jar javamake-1.2.12.jar
	
	cd ${S}/junit/external/
	java-pkg_jar-from ${JUNIT}

	cd ${S}/tasklist/external/
	java-pkg_jar-from jtidy Tidy.jar Tidy-r7.jar	

	cd ${S}/web/external
	java-pkg_jar-from ${SERVLET23}
	java-pkg_jar-from ${SERVLET24}	
	java-pkg_jar-from commons-el
	java-pkg_jar-from jaxen-1.1 jaxen-1.1_beta2.jar jaxen-full.jar
	java-pkg_jar-from saxpath
	java-pkg_jar-from ${JASPERCOMPILER}
	java-pkg_jar-from ${JASPERRUNTIME}
	java-pkg_jar-from ${JSPAPI}
	
}
src_compile()
{
	local antflags=""
	
	if use debug; then
		antflags="${antflags} -Dbuild.compiler.debug=true"
		antflags="${antflags} -Dbuild.compiler.deprecation=true"
	else
		antflags="${antflags} -Dbuild.compiler.deprecation=false"
	fi
	
	antflags="${antflags} -Dnetbeans.no.pre.unscramble=true"
	antflags="${antflags} -Dstop.when.broken.modules=true"

	# The build will attempt to display graphical
	# dialogs for the licence agreements if this is set.
	unset DISPLAY
	
	# Move into the folder where the build.xml file lives.
	cd ${S}/nbbuild
	
	# Specify the build-nozip target otherwise it will build
	# a zip file of the netbeans folder, which will copy directly.
	yes yes 2>/dev/null | 	ant ${antflags} build-nozip || die "Compiling failed!"

	#Remove non-x86 Linux binaries
	find ${BUILDDESTINATION} -type f -name "*.exe" -o -name "*.cmd" -o \
			                 -name "*.bat" -o -name "*.dll"	  \
			| xargs ${RM} -f	
}

symlink_extjars()
{
	cd ${1}/ide4/modules/ext
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.0.4.jar
	java-pkg_jar-from ${COMMONS_LOGGING}
	java-pkg_jar-from flute
	java-pkg_jar-from jmi
	java-pkg_jar-from ${JUNIT}
	java-pkg_jar-from mof
	java-pkg_jar-from sac

	cd ${1}/ide4/modules/autoload/ext
	java-pkg_jar-from commons-el
	java-pkg_jar-from ${SERVLET22}
	java-pkg_jar-from ${SERVLET23}
	java-pkg_jar-from ${SERVLET24}
	java-pkg_jar-from ${XERCES}
	java-pkg_jar-from ${JSR}
	java-pkg_jar-from ${JASPERCOMPILER}
	java-pkg_jar-from ${JASPERRUNTIME}
	java-pkg_jar-from ${XMLCOMMONS} 
	java-pkg_jar-from ${JSPAPI}

	cd ${1}/platform4/modules/ext
	java-pkg_jar-from ${JH}
}

src_install()
{	
	local TOMCATDIR="nb4.0/jakarta-tomcat-5.0.28"

	local DESTINATION="/usr/share/netbeans-${SLOT}"	
	
	insinto $DESTINATION

#Tomcat removal
	${RM} -fr ${BUILDDESTINATION}/${TOMCATDIR}

	cd ${BUILDDESTINATION}

#The program itself
	doins -r * 

	symlink_extjars ${D}/${DESTINATION}	

	fperms 755 \
		   ${DESTINATION}/bin/netbeans \
		   ${DESTINATION}/platform4/lib/nbexec
	
#The wrapper wrapper :)
	newbin ${FILESDIR}/startscript.sh netbeans-${SLOT}

#Linking to the system tomcat
	dodir /usr/share/tomcat-${TOMCATSLOT}
	dosym /usr/share/tomcat-${TOMCATSLOT} ${DESTINATION}/${TOMCATDIR}

#Ant stuff. We use the system ant.
	local ANTDIR="${DESTINATION}/ide4/ant"
	cd ${D}/${ANTDIR}

	${RM} -fr ./lib
	dodir /usr/share/ant-core/lib
	dosym /usr/share/ant-core/lib ${ANTDIR}/lib

	${RM} -fr ./bin
	dodir /usr/share/ant-core/bin
	dosym /usr/share/ant-core/bin  ${ANTDIR}/bin

#NOTICE THIS. We first installed everything here 
#and now we will remove some stuff from here and
#install it somewhere else instead.
 
	cd ${D}/${DESTINATION}
		
#Documentation

	#The next directory seems to be empty	
	if ! rmdir doc 2> /dev/null; then	
		use doc || ${RM} -fr ./doc
	fi

	use doc || ${RM} -fr ./nb4.0/docs
	use doc && java-pkg_dohtml -r ${WORKDIR}/javadoc/*

	dodoc build_info
	dohtml CREDITS.html README.html netbeans.css
	
	${RM} -f build_info CREDITS.html README.html netbeans.css

#Icons and shortcuts
	echo "Symlinking icons...."

	dodir ${DESTINATION}/icons
	insinto ${DESTINATION}/icons
	doins ${S}/core/ide/release/bin/icons/*png
	
	for res in "16x16" "24x24" "32x32" "48x48" "128x128"
	do
		dodir /usr/share/icons/hicolor/${res}/apps
		dosym ${DESTINATION}/icons/nb${res}.png /usr/share/icons/hicolor/${res}/apps/netbeans.png
	done

	make_desktop_entry netbeans-${SLOT} Netbeans netbeans Development
}

pkg_postinst ()
{
	einfo "Your tomcat directory might not have the right permissions."
	einfo "Please make sure that normal users can read the directory:"
	einfo "/usr/share/tomcat-${TOMCATSLOT}"
}
