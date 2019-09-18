# NMake Makefile portion for enabling features for Windows builds

# These are the base minimum libraries required for building glibmm.
BASE_INCLUDES =	/I$(PREFIX)\include

# Please do not change anything beneath this line unless maintaining the NMake Makefiles
GLIB_API_VERSION = 2.0

GLIBMM_MAJOR_VERSION = 2
GLIBMM_MINOR_VERSION = 64

LIBSIGC_MAJOR_VERSION = 3
LIBSIGC_MINOR_VERSION = 0

!if "$(CFG)" == "debug" || "$(CFG)" == "Debug"
DEBUG_SUFFIX = -d
!else
DEBUG_SUFFIX =
!endif

GLIBMM_BASE_CFLAGS =			\
	/I..\glib /I.\glibmm		\
	/wd4530 /std:c++17	\
	/FImsvc_recommended_pragmas.h

GIOMM_BASE_CFLAGS = /I..\gio /I.\giomm $(GLIBMM_BASE_CFLAGS)

GLIBMM_EXTRA_INCLUDES =	\
	/I$(PREFIX)\include\gio-win32-$(GLIB_API_VERSION)	\
	/I$(PREFIX)\include\glib-$(GLIB_API_VERSION)	\
	/I$(PREFIX)\lib\glib-$(GLIB_API_VERSION)\include	\
	/I$(PREFIX)\include\sigc++-$(LIBSIGC_MAJOR_VERSION).$(LIBSIGC_MINOR_VERSION)	\
	/I$(PREFIX)\lib\sigc++-$(LIBSIGC_MAJOR_VERSION).$(LIBSIGC_MINOR_VERSION)\include

LIBGLIBMM_CFLAGS = /DGLIBMM_BUILD /DSIZEOF_WCHAR_T=2 $(GLIBMM_BASE_CFLAGS) $(GLIBMM_EXTRA_INCLUDES)
LIBGIOMM_CFLAGS = /DGIOMM_BUILD /DSIZEOF_WCHAR_T=2 $(GIOMM_BASE_CFLAGS) $(GLIBMM_EXTRA_INCLUDES)
GLIBMM_EX_CFLAGS = $(GLIBMM_BASE_CFLAGS) $(GLIBMM_EXTRA_INCLUDES)
GIOMM_EX_CFLAGS = $(GIOMM_BASE_CFLAGS) $(GLIBMM_EXTRA_INCLUDES)

# We build glibmm-vc$(VSVER)0-$(GLIBMM_MAJOR_VERSION)_$(GLIBMM_MINOR_VERSION).dll or
#          glibmm-vc$(VSVER)0-d-$(GLIBMM_MAJOR_VERSION)_$(GLIBMM_MINOR_VERSION).dll at least
#          giomm-vc$(VSVER)0-$(GLIBMM_MAJOR_VERSION)_$(GLIBMM_MINOR_VERSION).dll or
#          giomm-vc$(VSVER)0-d-$(GLIBMM_MAJOR_VERSION)_$(GLIBMM_MINOR_VERSION).dll at least

LIBSIGC_LIBNAME = sigc-vc$(VSVER)0$(DEBUG_SUFFIX)-$(LIBSIGC_MAJOR_VERSION)_$(LIBSIGC_MINOR_VERSION)

LIBSIGC_DLL = $(LIBSIGC_LIBNAME).dll
LIBSIGC_LIB = $(LIBSIGC_LIBNAME).lib

GLIBMM_LIBNAME = glibmm-vc$(VSVER)0$(DEBUG_SUFFIX)-$(GLIBMM_MAJOR_VERSION)_$(GLIBMM_MINOR_VERSION)

GLIBMM_DLL = $(CFG)\$(PLAT)\$(GLIBMM_LIBNAME).dll
GLIBMM_LIB = $(CFG)\$(PLAT)\$(GLIBMM_LIBNAME).lib

GIOMM_LIBNAME = giomm-vc$(VSVER)0$(DEBUG_SUFFIX)-$(GLIBMM_MAJOR_VERSION)_$(GLIBMM_MINOR_VERSION)

GIOMM_DLL = $(CFG)\$(PLAT)\$(GIOMM_LIBNAME).dll
GIOMM_LIB = $(CFG)\$(PLAT)\$(GIOMM_LIBNAME).lib

GENDEF = $(CFG)\$(PLAT)\gendef.exe
GOBJECT_LIBS = gobject-2.0.lib gmodule-2.0.lib glib-2.0.lib
GIO_LIBS = gio-2.0.lib $(GOBJECT_LIBS)

GLIBMM_EX_LIBS = $(GLIBMM_LIB) $(LIBSIGC_LIB) $(GOBJECT_LIBS)
GIOMM_EX_LIBS = $(GIOMM_LIB) $(GLIBMM_LIB) $(LIBSIGC_LIB) $(GIO_LIBS)

# Set a default location for glib-compile-schemas, if not specified
!ifndef GLIB_COMPILE_SCHEMAS
GLIB_COMPILE_SCHEMAS = $(PREFIX)\bin\glib-compile-schemas
!endif
