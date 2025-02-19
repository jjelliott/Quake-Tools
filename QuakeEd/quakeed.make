# GNUstep Application Makefile for QuakeEd

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = QuakeEd
QuakeEd_OBJC_FILES = CameraView.m Clipper.m Dict.m DictList.m Entity.m \
                     EntityClass.m InspectorControl.m KeypairView.m Map.m \
                     PopScrollView.m Preferences.m Project.m QuakeEd.m \
                     SetBrush.m TexturePalette.m TextureView.m Things.m \
                     UserPath.m XYView.m ZScrollView.m ZView.m misc.m \
                     QuakeEd_main.m render.m

QuakeEd_C_FILES = cmdlib.c mathlib.c
QuakeEd_HEADER_FILES = CameraView.h Clipper.h Dict.h DictList.h Entity.h \
                       EntityClass.h InspectorControl.h KeypairView.h Map.h \
                       PopScrollView.h Preferences.h Project.h QuakeEd.h \
                       SetBrush.h TexturePalette.h TextureView.h Things.h \
                       UserPath.h XYView.h ZScrollView.h ZView.h render.h \
                       cmdlib.h mathlib.h

QuakeEd_RESOURCE_FILES = i_quakeed.tiff QuakeEd.nib DownArrow.tiff i_90d.tiff \
                         i_add.tiff i_brushes.tiff i_fliph.tiff i_flipv.tiff \
                         i_quakeed.tiff i_sub.tiff short.tiff tall.tiff \
                         UpArrow.tiff

# Linking against GNUstep libraries
QuakeEd_LIBS = -lgnustep-gui -lgnustep-base

# Installation path
APP_INSTALL_DIR = $(GNUSTEP_LOCAL_APPS)

# File permissions
INSTALL_MODE = 755

include $(GNUSTEP_MAKEFILES)/application.make