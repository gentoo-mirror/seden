# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils java-pkg-2

DESCRIPTION="Jetty Web Server; Java Servlet container"

SLOT="7"
HOMEPAGE="http://jetty.codehaus.org/"
KEYWORDS="~amd64 ~x86"
LICENSE="Apache-2.0 Eclipse-1.0"

MY_PV="${PV}.v20111024"
MY_PN="jetty"
MY_JETTY="${MY_PN}-${SLOT}"

IUSE="client ssl stats tomcat7"

SRC_URI="http://download.eclipse.org/${MY_PN}/stable-${SLOT}/dist/${MY_PN}-distribution-${MY_PV}.tar.gz"

#http://dist.codehaus.org/jetty/jetty-${PV}/jetty-${PV}.zip
#	anttasks? ( http://dist.codehaus.org/jetty/jetty-${PV}/jetty-ant-${PV}.jar )"
RESTRICT="mirror"

DEPEND="
  tomcat7? ( dev-java/tomcat-servlet-api:3.0 )
  !tomcat7? ( dev-java/tomcat-servlet-api:2.5 )
	!www-servers/jetty:${SLOT}
	!www-servers/jetty-eclipse:${SLOT}
	!www-servers/jetty-eclipse-bin:${SLOT}
	>=virtual/jre-1.5"

RDEPEND="${DEPEND}
	>=dev-java/slf4j-api-1.3.1
	>=dev-java/sun-javamail-1.4
	>=dev-java/jta-1.0.1
	>=java-virtuals/jaf-1.1"

S="${WORKDIR}/${MY_PN}-distribution-${MY_PV}"

src_install() {
    cd "${S}"

    java-pkg_jarinto "/usr/share/${MY_JETTY}/lib/"
    java-pkg_sointo "/usr/lib/${MY_JETTY}"

    java-pkg_dojar start.jar

    java-pkg_newjar lib/${MY_PN}-ajp-${MY_PV}.jar ${MY_PN}-ajp.jar
    java-pkg_newjar lib/${MY_PN}-all-${MY_PV}-javadoc.jar ${MY_PN}-all-javadoc.jar
    java-pkg_newjar lib/${MY_PN}-annotations-${MY_PV}.jar ${MY_PN}-annotations.jar
    java-pkg_newjar lib/${MY_PN}-continuation-${MY_PV}.jar ${MY_PN}-continuation.jar
    java-pkg_newjar lib/${MY_PN}-deploy-${MY_PV}.jar ${MY_PN}-deploy.jar
    java-pkg_newjar lib/${MY_PN}-http-${MY_PV}.jar ${MY_PN}-http.jar
    java-pkg_newjar lib/${MY_PN}-io-${MY_PV}.jar ${MY_PN}-io.jar
    java-pkg_newjar lib/${MY_PN}-jmx-${MY_PV}.jar ${MY_PN}-jmx.jar
    java-pkg_newjar lib/${MY_PN}-jndi-${MY_PV}.jar ${MY_PN}-jndi.jar
    java-pkg_newjar lib/${MY_PN}-overlay-deployer-${MY_PV}.jar ${MY_PN}-overlay-deployer.jar
    java-pkg_newjar lib/${MY_PN}-plus-${MY_PV}.jar ${MY_PN}-plus.jar
    java-pkg_newjar lib/${MY_PN}-policy-${MY_PV}.jar ${MY_PN}-policy.jar
    java-pkg_newjar lib/${MY_PN}-rewrite-${MY_PV}.jar ${MY_PN}-rewrite.jar
    java-pkg_newjar lib/${MY_PN}-security-${MY_PV}.jar ${MY_PN}-security.jar
    java-pkg_newjar lib/${MY_PN}-server-${MY_PV}.jar ${MY_PN}-server.jar
    java-pkg_newjar lib/${MY_PN}-servlet-${MY_PV}.jar ${MY_PN}-servlet.jar
    java-pkg_newjar lib/${MY_PN}-servlets-${MY_PV}.jar ${MY_PN}-servlets.jar
    java-pkg_newjar lib/${MY_PN}-util-${MY_PV}.jar ${MY_PN}-util.jar
    java-pkg_newjar lib/${MY_PN}-webapp-${MY_PV}.jar ${MY_PN}-webapp.jar
    java-pkg_newjar lib/${MY_PN}-websocket-${MY_PV}.jar ${MY_PN}-websocket.jar
    java-pkg_newjar lib/${MY_PN}-xml-${MY_PV}.jar ${MY_PN}-xml.jar
    java-pkg_newjar lib/annotations/javax.annotation_1.0.0.v20100513-0750.jar javax.annotation.jar
    java-pkg_newjar lib/annotations/org.objectweb.asm_3.1.0.v200803061910.jar org.objectweb.asm.jar
    java-pkg_newjar lib/jndi/javax.activation_1.1.0.v201005080500.jar javax.activation.jar
    java-pkg_newjar lib/jndi/javax.mail.glassfish_1.4.1.v201005082020.jar javax.mail.glassfish.jar
    java-pkg_newjar lib/jsp/${MY_PN}-jsp-2.1-${MY_PV}.jar ${MY_PN}-jsp.jar
    java-pkg_newjar lib/jsp/com.sun.el_1.0.0.v201004190952.jar com.sun.el.jar
    java-pkg_newjar lib/jsp/ecj-3.6.jar ecj.jar
    java-pkg_newjar lib/jsp/javax.el_2.1.0.v201004190952.jar javax.el.jar
    java-pkg_newjar lib/jsp/javax.servlet.jsp.jstl_1.2.0.v201004190952.jar javax.servlet.jsp.jstl.jar
    java-pkg_newjar lib/jsp/javax.servlet.jsp_2.1.0.v201004190952.jar javax.servlet.jsp.jar
    java-pkg_newjar lib/jsp/jsp-impl-2.1.3-b10.jar jsp-impl.jar
    java-pkg_newjar lib/jsp/org.apache.taglibs.standard.glassfish_1.2.0.v201004190952.jar org.apache.taglibs.standard.glassfish.jar
    java-pkg_newjar lib/jta/javax.transaction_1.1.1.v201004190952.jar javax.transaction.jar
    java-pkg_newjar lib/monitor/${MY_PN}-monitor-${MY_PV}.jar ${MY_PN}-monitor.jar
    java-pkg_newjar lib/servlet-api-2.5.jar servlet-api.jar

    use client && java-pkg_newjar lib/${MY_PN}-client-${MY_PV}.jar ${MY_PN}-client.jar
    if ! use ssl ; then
       rm -f etc/jetty-ssl.xml
    fi
    if ! use stats ; then
       rm -f etc/jetty-stats.xml
    fi

    dodir /etc/${MY_JETTY}
    insinto /etc/${MY_JETTY}
    doins etc/*

    dodir /etc/conf.d
    insinto /etc/conf.d
    newins ${FILESDIR}/conf.d/${MY_JETTY} ${MY_JETTY}

    dodir /etc/init.d
    exeinto /etc/init.d
    newexe ${FILESDIR}/init.d/${MY_JETTY} ${MY_JETTY}

    dodir /var/log/${MY_JETTY}

    JETTY_HOME=/var/lib/${MY_JETTY}
    dodir ${JETTY_HOME}/webapps
    dodir ${JETTY_HOME}/contexts
    dodir ${JETTY_HOME}/resources
    dosym ${JAVA_PKG_JARDEST} ${JETTY_HOME}/lib
    dosym ${JAVA_PKG_JARDEST}/start.jar ${JETTY_HOME}/start.jar
    dosym /etc/${MY_JETTY} ${JETTY_HOME}/etc
    dosym /var/log/${MY_JETTY} ${JETTY_HOME}/logs

    START_CONFIG=${D}/${JETTY_HOME}/start.config
    echo "\$(jetty.class.path).path                         always" > ${START_CONFIG}
    echo "\$(jetty.lib)/**                                  exists \$(jetty.lib)" >> ${START_CONFIG}
    echo "jetty.home=${JETTY_HOME}" >> ${START_CONFIG}
    echo "org.mortbay.xml.XmlConfiguration.class" >> ${START_CONFIG}
    echo "\$(start.class).class" >> ${START_CONFIG}
    echo "\$(jetty.home)/etc/jetty.xml" >> ${START_CONFIG}
    echo "\$(jetty.home)/lib/*" >> ${START_CONFIG}
    echo "/usr/share/sun-javamail/lib/*" >> ${START_CONFIG}
    echo "/usr/share/ant/lib/*" >> ${START_CONFIG}
    echo "/usr/share/slf4j-api/lib/*" >> ${START_CONFIG}
    echo "/usr/share/jta/lib/*" >> ${START_CONFIG}
    if use tomcat7 ; then
      echo "/usr/share/tomcat-servlet-api-3.0/lib/*" >> ${START_CONFIG}
    else
      echo "/usr/share/tomcat-servlet-api-2.5/lib/*" >> ${START_CONFIG}
    fi
    echo "" >> ${START_CONFIG}
    echo "\$(jetty.home)/resources/" >> ${START_CONFIG}
}

pkg_preinst () {
    enewuser jetty
    fowners jetty:jetty /var/log/${MY_JETTY}
    fperms g+w /var/log/${MY_JETTY}
    mv ${D}/usr/share/${PN}-${SLOT}/package.env ${D}/usr/share/${MY_JETTY}/package.env
    rm -rf ${D}/usr/share/${PN}-${SLOT}
}

