#include "networkmanager.h"

#include <QNetworkRequest>
#include <QSslConfiguration>

#include "id_std.h"

//#define DBG

namespace id
{
	static const QStringList _SpecialUrl(QStringList() << "wx" << "qq" << "wexin" << "wechat");
}

idNetworkAccessManager::idNetworkAccessManager(QObject *parent) :
    QNetworkAccessManager(parent)
{
	setObjectName("idNetworkAccessManager");
    Init();
}

idNetworkAccessManager::~idNetworkAccessManager()
{

}

QNetworkReply *	idNetworkAccessManager::createRequest ( Operation op, const QNetworkRequest & req, QIODevice * outgoingData )
{
    QNetworkRequest r(req);

#ifndef _HARMATTAN
    if(r.url().scheme() == "https")
    {
        QSslConfiguration config;
        config.setPeerVerifyMode(QSslSocket::VerifyNone);
        config.setProtocol(QSsl::TlsV1);
        r.setSslConfiguration(config);
    }
#endif

    HandleRequest(&r);

    return QNetworkAccessManager::createRequest(op, r, outgoingData);
}

bool idNetworkAccessManager::HandleRequest(QNetworkRequest *req)
{
    bool r;
    QString host = req->url().host();

    r = false;

    r = oHeaders.Request(req);

__Exit:
    return r;
}

QNetworkReply * idNetworkAccessManager::Request(const QString &url, const QByteArray &data, RequestMethod_e method)
{
    QNetworkReply *r;
    QNetworkRequest req(url);

    switch(method)
    {
    case idNetworkAccessManager::Request_Post:
        r = QNetworkAccessManager::post(req, data);
        break;
    case idNetworkAccessManager::Request_Get:
    default:
        r = QNetworkAccessManager::get(req);
        break;
    }

    return r;
}

void idNetworkAccessManager::Init()
{

    QNetworkCookieJar *cookieJar = idNetworkCookieJar::Instance();
    setCookieJar(cookieJar);
    cookieJar->setParent(0);

    oHeaders.SetPaths(id::_SpecialUrl);
    oHeaders.AddHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36");
    oHeaders.AddHeader("Referer", "https://wx.qq.com/");
}

void idNetworkAccessManager::SetRequestHeaders(const QVariantMap &headers)
{
    oHeaders.ClearHeaders();
    ID_CONST_FOREACH(QVariantMap, headers)
    {
        oHeaders.AddHeader(itor.key(), itor.value().toString());
    }
}

void idNetworkAccessManager::SetRequestHeaders(const QVariantList &headers)
{
    oHeaders.ClearHeaders();
    ID_CONST_FOREACH(QVariantList, headers)
    {
        QVariantMap m = itor->toMap();
        oHeaders.AddHeader(m["name"].toString(), m["value"].toString());
    }
}




// idDeclarativeNetworkAccessManagerFactory
idDeclarativeNetworkAccessManagerFactory::idDeclarativeNetworkAccessManagerFactory()
	: QDeclarativeNetworkAccessManagerFactory()
{
}

idDeclarativeNetworkAccessManagerFactory::~idDeclarativeNetworkAccessManagerFactory()
{
}

QNetworkAccessManager *	idDeclarativeNetworkAccessManagerFactory::create(QObject *parent)
{
	QMutexLocker lock(&oMutex);
	idNetworkAccessManager *manager = 0;

	manager = new idNetworkAccessManager(parent);
	return manager;
}




// idRequestHeaders
bool idRequestHeaders::B_Dbg = false;

idRequestHeaders::idRequestHeaders()
{

}

idRequestHeaders::~idRequestHeaders()
{

}

void idRequestHeaders::AddHeader(const QString &name, const QString &value)
{
	operator <<(qMakePair<QByteArray, QByteArray>(QByteArray().append(name), QByteArray().append(value)));
}

idRequestHeaders & idRequestHeaders::operator<<(const id::idRequestHeader_t &h)
{
	ID_FOREACH(id::idRequestHeaders_t, tHeaders)
	{
		if(itor->first == h.first)
		{
			itor->second = h.second;
			goto __Exit;
		}
	}

	tHeaders.push_back(h);

__Exit:
	return *this;
}

void idRequestHeaders::RemoveHeader(const QString &name)
{
	QByteArray n;

	n.append(name);
	ID_FOREACH(id::idRequestHeaders_t, tHeaders)
	{
		if(itor->first == n)
		{
			tHeaders.erase(itor);
			return;
		}
	}
}

idRequestHeaders & idRequestHeaders::operator>>(const QString &name)
{
	RemoveHeader(name);
	return *this;
}

id::idRequestHeaders_t idRequestHeaders::Headers() const
{
	return tHeaders;
}

void idRequestHeaders::ClearHeaders()
{
	tHeaders.clear();
}

bool idRequestHeaders::HasHeader(const QString &name)
{
	QByteArray n;

	n.append(name);
	ID_FOREACH(id::idRequestHeaders_t, tHeaders)
	{
		if(itor->first == n)
			return true;
	}
	return false;
}

bool idRequestHeaders::Request(QNetworkRequest *req)
{
	if(!req)
		return false;
	QString url = req->url().toString();
	if(url.isEmpty())
		return false;

	ID_FOREACH(QStringList, tPaths)
	{
		if(url.contains(*itor))
		{
			SetHeaders(req);
			return true;
		}
	}
	return false;
}

void idRequestHeaders::SetHeaders(QNetworkRequest *req)
{
	if(!req)
		return;

	ID_FOREACH(id::idRequestHeaders_t, tHeaders)
	{
		if(B_Dbg)
			qDebug() << itor->first << itor->second;
		req->setRawHeader(itor->first, itor->second);
	}
}

void idRequestHeaders::AddPath(const QString &path)
{
	if(tPaths.contains(path))
		return;
	tPaths.push_back(path);
}

void idRequestHeaders::SetPaths(const QStringList &list)
{
	tPaths = list;
}

QStringList idRequestHeaders::Paths() const
{
	return tPaths;
}

void idRequestHeaders::SetMethod(const QString &m)
{
	if(sMethod != m)
		sMethod = m;
}

QString idRequestHeaders::Method() const
{
	return sMethod;
}




// idNetworkCookieJar
	idNetworkCookieJar::idNetworkCookieJar(QObject *parent)
: QNetworkCookieJar(parent)
{
	setObjectName("idNetworkCookieJar");
	Dump();
}

idNetworkCookieJar::~idNetworkCookieJar()
{
	Restore();
}

idNetworkCookieJar * idNetworkCookieJar::Instance()
{
	static idNetworkCookieJar _cookieJar;
	return &_cookieJar;
}

void idNetworkCookieJar::Restore()
{

}

void idNetworkCookieJar::Dump()
{

}

void idNetworkCookieJar::RestoreCookie(const QByteArray &cookie)
{
	setAllCookies(QNetworkCookie::parseCookies(cookie));
}

QByteArray idNetworkCookieJar::DumpCookie(const QStringList &domain) const
{
	QByteArray data;
	QList<QNetworkCookie> cookie = allCookies();
	ID_CONST_FOREACH(QList<QNetworkCookie>, cookie)
	{
		if (!itor->isSessionCookie())
		{
			if(domain.isEmpty())
			{
				data.append(itor->toRawForm());
				data.append("\n");
				continue;
			}

			ID_CONST_FOREACH2(QStringList, domain, 2)
			{
				if(itor_2->contains(itor->domain()))
				{
					data.append(itor->toRawForm());
					data.append("\n");
					break;
				}
			}
		}
	}
	return data;
}

QList<QNetworkCookie>	idNetworkCookieJar::cookiesForUrl(const QUrl &url) const
{
	QList<QNetworkCookie> r = 
#if 1
		QNetworkCookieJar::cookiesForUrl(url);
#else
	QNetworkCookieJar::allCookies();
#endif
#ifdef DBG
	qDebug() << "GET-> " << url << r;
#endif
	return r;
}

bool idNetworkCookieJar::setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url)
{
#ifdef DBG
	qDebug() << "SET-> " << url << cookieList;
#endif
	return QNetworkCookieJar::setCookiesFromUrl(cookieList, url);
}
