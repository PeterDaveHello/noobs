#############################################################
#
# gutenprint
#
#############################################################

GUTENPRINT_VERSION = 5.2.9
GUTENPRINT_SITE = http://downloads.sourceforge.net/gimp-print/gutenprint-5.2/$(GUTENPRINT_VERSION)
GUTENPRINT_SOURCE = gutenprint-$(GUTENPRINT_VERSION).tar.bz2
GUTENPRINT_LICENSE = GPLv2+
GUTENPRINT_LICENSE_FILES = COPYING

# Needed, as we touch Makefile.am
GUTENPRINT_AUTORECONF = YES

GUTENPRINT_DEPENDENCIES = cups host-pkgconf \
	$(if $(BR2_PACKAGE_LIBICONV),libiconv)

# host-gutenprint is needed to generate XML as part of compilation
# the program that generates the xml also links against libgutenprint
# so we need to build both a host package and a target package
GUTENPRINT_DEPENDENCIES += host-gutenprint

GUTENPRINT_CONF_OPT = --disable-libgutenprintui2 \
                      --disable-samples \
                      --without-gimp2 \
                      --without-foomatic \
                      --without-foomatic3 \
                      --disable-escputil \
                      --disable-test \
                      --disable-testpattern \
                      --with-cups="/usr" \
                      --with-sysroot="$(STAGING_DIR)" \
                      --disable-cups-ppds

# USE_PREGEN_XMLI18N_TMP_H is added by our patch
GUTENPRINT_MAKE_ENV = BR2_USE_PREGEN_XMLI18N_TMP_H=$(HOST_DIR)/usr/include/xmli18n-tmp.h

# We have no host dependencies
HOST_GUTENPRINT_DEPENDENCIES =
# The host-gutenprint shall create the required header
HOST_GUTENPRINT_MAKE_ENV =

HOST_GUTENPRINT_CONF_OPT = --disable-libgutenprintui2 \
                           --disable-samples \
                           --without-gimp2 \
                           --without-doc \
                           --disable-nls \
                           --disable-nls-macos \
                           --without-foomatic \
                           --without-foomatic3 \
                           --disable-escputil \
                           --disable-test \
                           --disable-testpattern

# Needed by autoreconf
define GUTENPRINT_CREATE_M4_DIR
	mkdir -p $(@D)/m4local
endef
GUTENPRINT_POST_PATCH_HOOKS += GUTENPRINT_CREATE_M4_DIR

define HOST_GUTENPRINT_POST_BUILD_INSTAL_TMP_HEADER
	cp $(@D)/src/xml/xmli18n-tmp.h $(HOST_DIR)/usr/include
endef
HOST_GUTENPRINT_POST_BUILD_HOOKS += HOST_GUTENPRINT_POST_BUILD_INSTAL_TMP_HEADER

define GUTENPRINT_POST_INSTALL_TARGET_FIXUP
	mkdir -p $(TARGET_DIR)/usr/share/gutenprint/5.2
	cp -rf $(HOST_DIR)/usr/share/gutenprint/5.2/xml $(TARGET_DIR)/usr/share/gutenprint/5.2
endef
GUTENPRINT_POST_INSTALL_TARGET_HOOKS += GUTENPRINT_POST_INSTALL_TARGET_FIXUP

$(eval $(autotools-package))
$(eval $(host-autotools-package))
