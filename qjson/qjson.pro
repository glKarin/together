# TEMPLATE = lib
# TARGET = qjson
# DEPENDPATH += . src
# INCLUDEPATH += . src

# OBJECTS_DIR = ../.obj/qjson
# MOC_DIR = ../.moc/qjson

# CONFIG += static
# QT -= gui

QJSON_BASEDIR=qjson/

HEADERS += $${QJSON_BASEDIR}parser.h \
        $${QJSON_BASEDIR}parserrunnable.h \
                                $${QJSON_BASEDIR}qobjecthelper.h \
        $${QJSON_BASEDIR}serializer.h \
        $${QJSON_BASEDIR}serializerrunnable.h \
        $${QJSON_BASEDIR}qjson_export.h \
                                $${QJSON_BASEDIR}parserrunnable.h \
                                $${QJSON_BASEDIR}serializerrunnable.h

SOURCES += $${QJSON_BASEDIR}parser.cpp $${QJSON_BASEDIR}qobjecthelper.cpp $${QJSON_BASEDIR}json_scanner.cpp $${QJSON_BASEDIR}json_parser.cc $${QJSON_BASEDIR}parserrunnable.cpp $${QJSON_BASEDIR}serializer.cpp $${QJSON_BASEDIR}serializerrunnable.cpp
