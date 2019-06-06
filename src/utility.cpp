#include "utility.h"

#include <QSettings>
#include <QApplication>
#include <QClipboard>
#include <QDeclarativeEngine>
#include <QProcess>
#include <QStringList>
#include <QDebug>
#include <QDir>
#include <QDesktopServices>
#ifdef _MAEMO_MEEGOTOUCH_INTERFACES_DEV
#include <maemo-meegotouch-interfaces/videosuiteinterface.h>
#else
#define ID_VIDEO_SUITE "/usr/bin/video-suite"
#endif

#include "networkmanager.h"
#include "id_std.h"

#define ID_SETTING_VERSION 3

namespace id
{
	static QVariantHash _tDefaultSettings;
	static void InitDefaultSettings()
	{
		if(_tDefaultSettings.count() > 0)
			return;

		_tDefaultSettings.insert("setting_version", ID_SETTING_VERSION);
		_tDefaultSettings.insert("show_warning", true);

		_tDefaultSettings.insert("generals/orientation", 0);
		_tDefaultSettings.insert("generals/theme_color", 0);
		_tDefaultSettings.insert("generals/night_mode", false);
		_tDefaultSettings.insert("generals/default_browser", 1);
		_tDefaultSettings.insert("generals/fullscreen", false);
		_tDefaultSettings.insert("generals/check_update", true);

		_tDefaultSettings.insert("chat/sync_interval", 5);
		_tDefaultSettings.insert("chat/sync_background", 60);
		_tDefaultSettings.insert("chat/online_background", 10);
		_tDefaultSettings.insert("chat/online_check", false);
		_tDefaultSettings.insert("generals/run_mode", 1);

		_tDefaultSettings.insert("browser/helper", false);
		_tDefaultSettings.insert("browser/dbl_zoom", false);
		_tDefaultSettings.insert("browser/load_image", true);
	}

}

idUtility::idUtility(QObject *parent) :
	QObject(parent),
	oSettings(new QSettings(QSettings::UserScope, ID_DEV, ID_PKG, this)),
	iDev(
#ifdef _DBG
			2
#else
			0
#endif
			),
	eRunMode(idUtility::RunMode_Only_Hide_Window)
{
	setObjectName("idUtility");
	Init();
}

idUtility::~idUtility()
{

}

void idUtility::Init()
{
	int rm;
	const QList<int> AllowRunModes(QList<int>() << idUtility::RunMode_Not_Run_On_Background << idUtility::RunMode_Only_Hide_Window);

	id::InitDefaultSettings();
	rm = GetSetting<int>("generals/run_mode");
	if(AllowRunModes.contains(rm))
		eRunMode = static_cast<idUtility::idRunMode_e>(rm);

#ifdef _DBG
	if(Dev() == 2)
	{
		eRunMode = idUtility::RunMode_Close_Window; // reload QML viewer
	}
#endif
}

idUtility * idUtility::Instance()
{
	static idUtility _ut;
	return &_ut;
}

int idUtility::Dev() const
{
	return iDev;
}

void idUtility::SetDev(int d)
{
	int nd = d;
	if(nd < 0)
		nd = 0;
	if(iDev != nd)
	{
		iDev = nd;
		emit devChanged(iDev);
	}
}

QVariant idUtility::GetSetting(const QString &name)
{
	if(!id::_tDefaultSettings.contains(name))
		return QVariant();

	return oSettings->value(name, id::_tDefaultSettings.value(name));
}

void idUtility::SetSetting(const QString &name, const QVariant &value)
{
	if(!id::_tDefaultSettings.contains(name))
		return;

	oSettings->setValue(name, value);
}

void idUtility::OpenPlayer(const QString &url, int t) const
{
#ifdef _HARMATTAN
#ifdef _MAEMO_MEEGOTOUCH_INTERFACES_DEV
	VideoSuiteInterface player;
	player.play(QStringList(url));
#else
	QProcess::startDetached(VIDEO_SUITE, QStringList(url));
#endif
#elif defined(_SYMBIAN)
	QString path = QDir::tempPath();
	QDir dir(path);
	if (!dir.exists()) dir.mkpath(path);
	QString ramPath = path+"/video.ram";
	QFile file(ramPath);
	if (file.exists()) file.remove();
	if (file.open(QIODevice::ReadWrite)){
		QTextStream out(&file);
		out << url;
		file.close();
		QDesktopServices::openUrl(QUrl("file:///"+ramPath));
	}
#else
	qDebug() << "[DEBUG]: Open player -> " << url << t;
#endif
}

void idUtility::CopyToClipboard(const QString &text) const
{
	QApplication::clipboard()->setText(text);
}

QVariant idUtility::ResetSetting(const QString &name)
{
	if(name.isEmpty())
	{
		for(QVariantHash::const_iterator itor = id::_tDefaultSettings.constBegin();
				itor != id::_tDefaultSettings.constEnd(); ++itor)
		{
			oSettings->setValue(itor.key(), itor.value());
		}
		return QVariant(id::_tDefaultSettings);
	}
	else
	{
		if(id::_tDefaultSettings.contains(name))
		{
			oSettings->setValue(name, id::_tDefaultSettings.value(name));
			return oSettings->value(name);
		}
	}
	return QVariant();
}

void idUtility::Print_r(const QVariant &v) const
{
	qDebug() << v;
}

void idUtility::SetRequestHeaders(const QVariant &v)
{
	QNetworkAccessManager *qmanager;
	idNetworkAccessManager *manager;

	if(!oEngine)
		return;

	qmanager = oEngine->networkAccessManager();
	manager = dynamic_cast<idNetworkAccessManager *>(qmanager);

	if(!manager)
		return;

	if(v.canConvert<QVariantList>())
		manager->SetRequestHeaders(v.toList());
	else if(v.canConvert<QVariantMap>())
		manager->SetRequestHeaders(v.toMap());
}

void idUtility::SetEngine(QDeclarativeEngine *e)
{
	oEngine = e;
}

QDeclarativeEngine * idUtility::Engine()
{
	return oEngine;
}

QString idUtility::Sign(const QVariantMap &args, const QString &suffix, const QVariantMap &sysArgs) const
{
#define MAKE_QUERY(k, v) k + "=" + QUrl::toPercentEncoding(v)
	typedef QMap<QString, QString> idStringMap_t;

	QString r;
	idStringMap_t map;
	idStringMap_t map2;
	QStringList list;

	ID_CONST_FOREACH(QVariantMap, args)
	{
		map.insert(itor.key(), itor.value().toString());
	}
	ID_CONST_FOREACH(QVariantMap, sysArgs)
	{
		QString key = itor.key();
		if(map.contains(key))
			map2.insert(key, itor.value().toString());
		else
			map.insert(key, itor.value().toString());
	}
	ID_CONST_FOREACH(idStringMap_t, map)
	{
		QString key = itor.key();
		if(map2.contains(key))
		{
			list.push_back(MAKE_QUERY(key, map2[key]));
		}
		list.push_back(MAKE_QUERY(key, itor.value()));
	}
	r = list.join("&") + suffix;
	//qDebug() << r;
	return id::md5(r);
#undef MAKE_QUERY
}

QVariant idUtility::Get(const QString &name) const
{
#define ID_QT qVersion()
#define ID_WONGKAKUI QObject::tr("June, belongs to you forever, you have been away for %1 year. Seeing you in paradise far away.")
#ifdef _DBG
#define ID_ICON_PATH QDir::cleanPath(QCoreApplication::applicationDirPath() + "/" ID_PKG "80.png")
#define ID_CACHE_PATH QFileInfo(".").absoluteFilePath()
#define ID_SPLASH QFileInfo(".").absoluteFilePath() + "/res/" ID_PKG ".jpg"
#else
#define ID_ICON_PATH "/usr/share/icons/hicolor/80x80/apps/" ID_PKG "80.png"
#define ID_CACHE_PATH QDesktopServices::storageLocation(QDesktopServices::TempLocation)
#define ID_SPLASH "/opt/" ID_PKG "/res/" ID_PKG ".jpg"
#endif
	QVariant r;

	if(name.isEmpty())
	{
		QVariantMap map;
#define ID_M_I(x) map.insert(#x, ID_##x)
		ID_M_I(PATCH);
		ID_M_I(RELEASE);
		ID_M_I(DEV);
		ID_M_I(VER);
		ID_M_I(CODE);
		ID_M_I(STATE);
		ID_M_I(EMAIL);
		ID_M_I(GITHUB);
		ID_M_I(PAN);
		ID_M_I(OPENREPOS);
		ID_M_I(PKG);
		ID_M_I(APP);
		ID_M_I(TMO);
		ID_M_I(DESC);
		ID_M_I(WONGKAKUI);
		ID_M_I(PLATFORM);
		ID_M_I(QT);
		ID_M_I(ICON_PATH);
		ID_M_I(NAME);
		ID_M_I(BUID);
		ID_M_I(CACHE_PATH);
		ID_M_I(SPLASH);
		ID_M_I(APPID);
#undef _NL_M_I
		r.setValue(map);
	}
	else
	{
		QString n = name.toUpper();
#define ID_I(x) if(n == #x) { r.setValue(QString(ID_##x)); }
		ID_I(PATCH)
			else ID_I(RELEASE)
			else ID_I(DEV)
			else ID_I(VER)
			else ID_I(CODE)
			else ID_I(STATE)
			else ID_I(EMAIL)
			else ID_I(GITHUB)
			else ID_I(PAN)
			else ID_I(OPENREPOS)
			else ID_I(PKG)
			else ID_I(APP)
			else ID_I(TMO)
			else ID_I(DESC)
			else ID_I(WONGKAKUI)
			else ID_I(PLATFORM)
			else ID_I(QT)
			else ID_I(ICON_PATH)
			else ID_I(NAME)
			else ID_I(BUID)
			else ID_I(CACHE_PATH)
			else ID_I(SPLASH)
			else ID_I(APPID)
			else r.setValue(QProcessEnvironment::systemEnvironment().value(name));
#undef _NL_I
	}
	return r;
#undef ID_QT
#undef ID_WONGKAKUI
#undef ID_ICON_PATH
#undef ID_CACHE_PATH
}

QVariant idUtility::Changelog(const QString &version) const
{
	QVariantMap m;
	QStringList list;

	if(version.isEmpty())
	{
		list 
			<< QObject::tr("Fixed some user(redirect to wx2.qq.com) login.")
			<< QObject::tr("Add subscribe and article.")
			<< QObject::tr("Add update ckecking by OpenRepos.net.")
			<< QObject::tr("Add repeat to send empty message to filehelper for keeping connection(TESTING).")
			<< QObject::tr("Some fixes.")
			;
	}

	// read from changelog?
	m.insert("CHANGES", list);
	m.insert("PKG_NAME", QVariant());
	m.insert("RELEASE", QVariant());
	m.insert("DEVELOPER", QVariant());
	m.insert("EMAIL", QVariant());
	m.insert("URGENCY", QVariant());
	m.insert("STATE", QVariant());
	m.insert("VERSION", QVariant());

	return QVariant::fromValue<QVariantMap>(m);
}

QString idUtility::Uncompress(const QString &src, int windowbits) const
{
	QByteArray b;

	if(id::iduncompress(&b, QByteArray::fromBase64(QByteArray().append(src)), windowbits) == 0)
		return b;
	return QString();
}

QVariant idUtility::XML_Parse(const QString &xml) const
{
	return id::qvariant_from_xml(xml);
}

QVariant idUtility::GetDefaultSetting(const QString &name) const
{
	if(name.isEmpty())
		return QVariant(id::_tDefaultSettings);
	return id::_tDefaultSettings.value(name);
}

QString idUtility::FormatUrl(const QString &u) const
{
	int dot, slash;
	QUrl url(u);

	if(url.isValid())
	{
		if(url.scheme().isEmpty())
		{
			if(url.isRelative())
			{
				if(u.at(0) == '.')
					return QString("file://") + QDir::cleanPath(QCoreApplication::applicationDirPath() + "/" + u);
				else if(u.at(0) == '/')
					return QString("file://") + u;
				else
				{
					dot = u.indexOf('.');
					slash = u.indexOf('/');
					if(dot != -1 || slash != -1)
					{
						if(slash == -1 || dot < slash - 1)
							return QString("http://") + u;
					}
					else if(u.indexOf("localhost") == 0)
						return QString("http://") + u;
				}
			}
			else
				return QString("http://") + u;
		}
		else
			return url.toString();
	}
	return QString();
}

qint64 idUtility::System(const QString &path, const QVariant &args, bool async) const
{
	qint64 pid;
	QStringList list;

	list = args.toStringList();

	if(async)
	{
		if(QProcess::startDetached(path, list, QString(), &pid))
			return pid;
		return -1;
	}
	else
		return QProcess::execute(path, list);
}

void idUtility::CheckUpdate()
{
	int ver;
	bool u;

	ver = 0;
	u = true;
	if(oSettings->contains("setting_version"))
	{
		ver = oSettings->value("setting_version").toInt();
		if(ver >= ID_SETTING_VERSION)
			u = false;
	}
	
	if(u)
	{
		oSettings->setValue("setting_version", ID_SETTING_VERSION);
		oSettings->setValue("show_warning", true);
		emit hasUpdate(ID_SETTING_VERSION);
	}
}

QVariant idUtility::ParseUrl(const QString &url, const QString &part) const
{
	typedef QPair<QString, QString> idStringPair_t;
	QUrl u(url);
	QString p = part.toUpper();

	if(u.isEmpty())
		return QVariant();

	if(p == "HOST")
		return u.host();
	else if(p == "PORT")
		return u.port();
	else if(p == "SCHEME")
		return u.scheme();
	else if(p == "PATH")
		return u.path();
	else if(p == "PARAMS")
	{
		QVariantMap r;
		QList<QPair<QString, QString> > querys = u.queryItems();
		ID_CONST_FOREACH(QList<idStringPair_t>, querys)
		{
			r.insert(itor->first, itor->second);
		}
		return r;
	}
	else if(p == "PARAM")
	{
		QStringList r;
		QList<QPair<QString, QString> > querys = u.queryItems();
		ID_CONST_FOREACH(QList<idStringPair_t>, querys)
		{
			r.push_back(itor->first + "=" + itor->second);
		}
		return r.join("&");
	}
	else
	{
		QVariantMap m;
		m.insert("HOST", u.host());
		m.insert("PORT", u.port());
		m.insert("SCHEME", u.scheme());
		m.insert("PATH", u.path());
		{
			QVariantMap r;
			QList<QPair<QString, QString> > querys = u.queryItems();
			ID_CONST_FOREACH(QList<idStringPair_t>, querys)
			{
				r.insert(itor->first, itor->second);
			}
			m.insert("PARAMS", r);
		}
		return m;
	}
}

QVariant idUtility::GetCookie(const QString &url) const
{
	QVariant r;
	QList<QNetworkCookie> cookies = idNetworkCookieJar::Instance()->cookiesForUrl(QUrl(url));
	if(cookies.count() > 0)
	{
		QVariantMap m;
		ID_CONST_FOREACH(QList<QNetworkCookie>, cookies)
		{
			// qDebug() << c.name() << c.value();
			m.insert(itor->name(), itor->value());
		}
		r.setValue(m);
	}
	return r;
}

QString idUtility::CacheFile(const QString &b64, const QString &name) const
{
	QString file(name.isEmpty() ? QString::number(QDateTime::currentMSecsSinceEpoch()) : name);
	QByteArray data = QByteArray::fromBase64(QByteArray().append(b64));
	QString cachePath = Get("CACHE_PATH").toString();
	file = cachePath + "/" + file;
	if(id::file_put_contents(file, data))
		return file;
	else
		return "";
}

idUtility::idRunMode_e idUtility::RunMode() const
{
	return eRunMode;
}

void idUtility::SetRequestHeader(const QString &k, const QString &v)
{
	QNetworkAccessManager *qmanager;
	idNetworkAccessManager *manager;

	if(!oEngine)
		return;

	qmanager = oEngine->networkAccessManager();
	manager = dynamic_cast<idNetworkAccessManager *>(qmanager);

	if(!manager)
		return;

	manager->SetRequestHeader(k, v);
}
