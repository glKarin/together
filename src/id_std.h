#ifndef ID_STD_H
#define ID_STD_H

#include <QVariant>

#define ID_APP "Together"
#define ID_NAME QObject::tr("Together")
#define ID_PKG "together"
#define ID_VER "2014.0.6harmattan1"
#define ID_CODE "paradise"
#define ID_DEV "karin"
#define ID_RELEASE "20140405"
#define ID_PATCH "1"
#define ID_STATE "devel"
#define ID_GITHUB "https://github.com/glKarin/together"
#define ID_PAN "https://pan.baidu.com/s/1HmOUVC4tHsSBtvoJX9ERFg 9mpm"
#define ID_OPENREPOS "https://openrepos.net/content/karinzhao/togetherwebwx"
#define ID_EMAIL "beyondk2000@gmail.com"
#define ID_TMO "http://talk.maemo.org/member.php?u=70254"
#define ID_DESC QObject::tr("Together is a simple ****** client, based on Web-API.")
#define ID_BUID "beyondk2000"
#define ID_APPID "10672"
#ifdef _HARMATTAN
#define ID_PLATFORM "MeeGo 1.2 Harmattan"
#else
#define ID_PLATFORM "Symbian"
#endif

#define ID_FOREACH(T, t) for(T::iterator itor = t.begin(); itor != t.end(); ++itor)
#define ID_CONST_FOREACH(T, t) for(T::const_iterator itor = t.constBegin(); itor != t.constEnd(); ++itor)
#define ID_FOREACH2(T, t, n) for(T::iterator itor_##n = t.begin(); itor_##n != t.end(); ++itor_##n)
#define ID_CONST_FOREACH2(T, t, n) for(T::const_iterator itor_##n = t.constBegin(); itor_##n != t.constEnd(); ++itor_##n)
#define ID_UNTIL(condition) while(!(condition))

#define ID_QML_URI ID_DEV"."ID_PKG
#define ID_QML_MAJOR_VER 1
#define ID_QML_MINOR_VER 0

#define ungzip(dst, src) iduncompress(dst, src, 32 + 15)
#define unz(dst, src) iduncompress(dst, src, -15)

namespace id
{
	QString md5(const QString &src);
	QString md5_b64(const QString &src);
	int iduncompress(QByteArray *dst, const QByteArray &data, int windowbits);
	QVariant qvariant_from_xml(const QString &xml);
	bool file_put_contents(const QString &file, const QByteArray &data, int mode = 0);
}

#endif // ID_STD_H
