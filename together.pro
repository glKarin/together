# Add more folders to ship with the application, here
folder_01.source = qml/together
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:TARGET.UID3 = 0xE0643D87

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
CONFIG += qdeclarative-boostable

# Add dependency to Symbian components
# CONFIG += qt-components

js.source = qml/js
js.target = qml
DEPLOYMENTFOLDERS += js

QT += declarative network sql webkit xml
CONFIG += mobility
MOBILITY += multimedia gallery systeminfo
INCLUDEPATH += . src src/qtm
DEFINES += _KARIN_MM_EXTENSIONS
MOC_DIR = .moc
OBJECTS_DIR = .obj
DEFINES += _HARMATTAN
#DEFINES += _DBG
DEFINES += _MAEMO_MEEGOTOUCH_INTERFACES_DEV
CONFIG += videosuiteinterface-maemo-meegotouch meegotouch
PKGCONFIG += zlib
#DEFINES += _VHAS_LIBQJSON_DEV

!contains(DEFINES, _VHAS_LIBQJSON_DEV) {
include(qjson/qjson.pro)
DEFINES += _LOCAL_QJSON_DEV
INCLUDEPATH += $${QJSON_BASEDIR}
DEPENDPATH += $${QJSON_BASEDIR}
DEFINES += QJSON_MAKEDLL
} else {
LIBS += -lqjson
}

contains(DEFINES, _KARIN_MM_EXTENSIONS) {
HEADERS += \
src/qtm/qdeclarativemediabase_p.h \
src/qtm/qdeclarativevideo_p.h \
src/qtm/qdeclarativemediametadata_p.h \
src/qtm/qpaintervideosurface_p.h

SOURCES += \
src/qtm/qdeclarativemediabase.cpp \
src/qtm/qdeclarativevideo.cpp \
src/qtm/qpaintervideosurface.cpp
}

contains(MEEGO_EDITION,harmattan){
PKGCONFIG += zlib
QT += dbus
DEFINES += _HARMATTAN
DEFINES += _MAEMO_MEEGOTOUCH_INTERFACES_DEV
CONFIG += videosuiteinterface-maemo-meegotouch meegotouch
#DEFINES += _VHAS_LIBQJSON_DEV

eventtype.files = misc/together.conf
eventtype.path = /usr/share/meegotouch/notifications/eventtypes
mime.files = misc/mime.types
mime.path = /opt/together/misc

INSTALLS += eventtype mime

icons.files = \
misc/icon-m-low-power-mode-together.png \
misc/icon-s-status-notifier-together.png \
misc/icon-m-service-together.png \     
misc/icon-s-status-together.png
icons.path = /usr/share/themes/blanco/meegotouch/icons
}

simulator {
DEFINES += _SIMULATOR
INCLUDEPATH += libs\include
LIBS += -LD:\qobj\q\weibomm\libs -lzlib1
}

symbian {
}

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    src/utility.cpp \
    src/networkmanager.cpp \
    src/networkconnector.cpp \
		src/id_std.cpp \
		src/pipeline.cpp \
		src/qmlimage.cpp \
		src/qmlmodel_base.cpp \
		src/transfermanager.cpp \
		src/transfertask_base.cpp \
		src/downloadtask.cpp \
		src/uploadtask.cpp \
		src/cache.cpp \
		src/database.cpp \
		src/transferrecord.cpp \
		src/filemodel.cpp \
		src/audiorecorder.cpp \
    src/qtm/qdeclarativewebview.cpp

splash.files = misc/together.jpg
splash.path = /opt/together/misc

i18n.source = i18n
i18n.target = .

resc.source = qml/resc
resc.target = qml

DEPLOYMENTFOLDERS += i18n resc

INSTALLS += splash

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog

HEADERS += \
    src/utility.h \
    src/networkmanager.h \
    src/networkconnector.h \
    src/id_std.h \
		src/pipeline.h \
		src/qmlimage.h \
		src/qmlmodel_base.h \
		src/transfermanager.h \
		src/transfertask_base.h \
		src/downloadtask.h \
		src/uploadtask.h \
		src/cache.h \
		src/database.h \
		src/transferrecord.h \
		src/filemodel.h \
		src/audiorecorder.h \
    src/qtm/qdeclarativewebview.h
