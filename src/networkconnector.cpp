#include "networkconnector.h"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDeclarativeEngine>
#include <QApplication>
#include <QDateTime>
#include <QStringList>
#include <QEventLoop>
#include <QApplication>
#include <QDebug>

#include "id_std.h"
#include "networkmanager.h"
#include "utility.h"
#include "qmlapplicationviewer.h"

extern QmlApplicationViewer *qml_viewer;

	idNetworkConnector::idNetworkConnector(QObject *parent)
: QObject(parent)
{
	setObjectName("idNetworkConnector");
}

idNetworkConnector::~idNetworkConnector()
{
	ID_QOBJECT_DESTROY_DBG
}

QString idNetworkConnector::Request(const QString &url, const QString &field, const QByteArray &data, int type, const QVariant &headers)
{
	QNetworkAccessManager *manager;
	QNetworkReply *reply;
	QString r;

	reply = 0;
	manager = NetworkManager();
	if(!manager)
	{
		return r;
	}

	QNetworkRequest req(url);

	if(!headers.isNull())
	{
		if(headers.canConvert<QVariantList>())
			SetRequestHeaders(&req, headers.toList());
		else if(headers.canConvert<QVariantMap>())
			SetRequestHeaders(&req, headers.toMap());
	}

	if(type == idNetworkConnector::Connect_Post)
		reply = manager->post(req, data);
	else if(type == idNetworkConnector::Connect_Put)
		reply = manager->put(req, data);
	else if(type == idNetworkConnector::Connect_Delete)
		reply = manager->deleteResource(req);
	else
		reply = manager->get(req);

	connect(reply, SIGNAL(finished()), this, SLOT(finishedSLOT()));
	r = QString("%1-%2").arg(field).arg(QDateTime::currentMSecsSinceEpoch());
	tReplys.insert(reply, r);

	return r;
}

void idNetworkConnector::SetRequestHeaders(QNetworkRequest *req, const QVariantMap &headers)
{
	ID_CONST_FOREACH(QVariantMap, headers)
	{
		req->setRawHeader(QByteArray().append(itor.key()), itor.value().toByteArray());
	}
}

void idNetworkConnector::SetRequestHeaders(QNetworkRequest *req, const QVariantList &headers)
{
	ID_CONST_FOREACH(QVariantList, headers)
	{
		QVariantMap m = itor->toMap();
		req->setRawHeader(m["name"].toByteArray(), m["value"].toByteArray());
	}
}

void idNetworkConnector::finishedSLOT()
{
	QObject *s;
	QNetworkReply *reply;
	int err;
	QString value;
	QByteArray b;
	QByteArray data;
	bool op;

	s = sender();
	reply = dynamic_cast<QNetworkReply *>(s);
	if(reply)
	{
		err = reply->error();
		if(err == QNetworkReply::NoError)
		{
        data = reply->readAll();
				QString encoding = reply->rawHeader("Content-Encoding");
				if(encoding == "gzip")
				{
					if(id::ungzip(&b, data) != 0)
						err = idNetworkConnector::Error_Reply_Data_Uncompress_Fail;
					else
						value = b;
				}
				else if(encoding == "deflate")
				{
					if(id::unz(&b, data) != 0)
						err = idNetworkConnector::Error_Reply_Data_Uncompress_Fail;
					else
						value = b;
				}
				else
				{
					value = data;
				}
		}
		else
			value = reply->errorString();

		reply->deleteLater();
	}
	else
		err = idNetworkConnector::Error_Reply_Not_Found;

	QString name = tReplys.take(reply);
	if(name.isEmpty())
		err = idNetworkConnector::Error_Request_Field_Not_Found;

	if(err < 0)
		value = ErrorString(err);
	else if(err == QNetworkReply::NoError)
	{
		QStringList sl = name.split("-");
		if(sl[0].startsWith("FILE") && sl.size() > 1)
		{
			QString file(idUtility::Instance()->Get("CACHE_PATH").toString() + "/" + sl[1]);
			op = id::file_put_contents(file, data);
			if(op)
				value = file;
			else
			{
				err = idNetworkConnector::Error_Data_Write_Fail;
				value = ErrorString(err);
			}
		}
		else if(sl[0].startsWith("BASE64"))
		{
			value = data.toBase64();
		}
	}

	emit finished(name, err, value);
}

idNetworkConnector * idNetworkConnector::Instance()
{
	static idNetworkConnector Connector;
	return &Connector;
}

QNetworkAccessManager * idNetworkConnector::NetworkManager()
{
	if(!qml_viewer)
		return 0;

	return qml_viewer->engine()->networkAccessManager();
}

QString idNetworkConnector::ErrorString(int err) const
{
	if(err == 0)
		return tr("No error");
	else if(err > 0)
		return tr("QNetworkReply Error");
	else
	{
		switch(err)
		{
			case idNetworkConnector::Error_Connector_Not_Inititalized:
				return tr("Network access manager is not initialized");
			case idNetworkConnector::Error_Reply_Data_Uncompress_Fail:
				return tr("Uncompress reply data error");
			case idNetworkConnector::Error_Reply_Not_Found:
				return tr("Reply is null");
			case idNetworkConnector::Error_Request_Field_Not_Found:
				return tr("Missing request info");
			case idNetworkConnector::Error_Data_Write_Fail:
				return tr("Data write fail");
			default:
				return tr("Other connector error");
		}
	}
}

id::idReplyHash_t idNetworkConnector::Replys() const
{
	return tReplys;
}

QString idNetworkConnector::Request_sync(const QString &url, const QByteArray &data, int type, const QVariant &headers)
{
	QNetworkAccessManager *manager;
	QNetworkReply *reply;
	QString r;
	bool ok;

	reply = 0;
	manager = NetworkManager();
	if(!manager)
	{
		return r;
	}

	QNetworkRequest req(url);

	if(!headers.isNull())
	{
		if(headers.canConvert<QVariantList>())
			SetRequestHeaders(&req, headers.toList());
		else if(headers.canConvert<QVariantMap>())
			SetRequestHeaders(&req, headers.toMap());
	}

	QEventLoop loop;
	connect(qApp, SIGNAL(aboutToQuit()), &loop, SLOT(quit()));

	if(type == idNetworkConnector::Connect_Post)
		reply = manager->post(req, data);
	else if(type == idNetworkConnector::Connect_Put)
		reply = manager->put(req, data);
	else if(type == idNetworkConnector::Connect_Delete)
		reply = manager->deleteResource(req);
	else
		reply = manager->get(req);

	connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
	if(!reply->isFinished())
		loop.exec(QEventLoop::ExcludeUserInputEvents);
	if(!reply->isFinished())
	{
		reply->abort();
		reply->deleteLater();
		return r;
	}

	QByteArray bytes = reply->readAll();
	QByteArray b;
	ok = true;
	QString encoding = reply->rawHeader("Content-Encoding");
	if(encoding == "gzip")
	{
		if(id::ungzip(&b, bytes) != 0)
		{
			//qWarning() << "[Warning]: Ungzip error -> " << url;
			ok = false;
		}
	}
	else if(encoding == "deflate")
	{
		if(id::unz(&b, bytes) != 0)
		{
			//qWarning() << "[Warning]: Unz error -> " << url;
			ok = false;
		}
	}
	reply->deleteLater();

	return QString(ok ? b : bytes);
}

int idNetworkConnector::SyncRequest(const QString &url, const QList<QPair<QByteArray, QByteArray> > &querys, const QByteArray &data, int type, const QVariant &headers, QByteArray *r, bool redirect)
{
	QNetworkAccessManager *manager;
	QNetworkReply *reply;
	QUrl u;
	int ret;
	bool ok;
	int statusCode;
	bool has_redirect;

	reply = 0;
	ret = -1;
	has_redirect = false;
	manager = NetworkManager();
	if(!manager)
	{
		return ret;
	}

	u.setUrl(url);
	if(!querys.isEmpty())
	{
		u.setEncodedQueryItems(querys);
	}

	QEventLoop loop;
	QNetworkRequest req;
	connect(qApp, SIGNAL(aboutToQuit()), &loop, SLOT(quit()));

	if(!headers.isNull())
	{
		if(headers.canConvert<QVariantList>())
			SetRequestHeaders(&req, headers.toList());
		else if(headers.canConvert<QVariantMap>())
			SetRequestHeaders(&req, headers.toMap());
	}

__Redirection:
	req.setUrl(u);
	if(type == idNetworkConnector::Connect_Post)
		reply = manager->post(req, data);
	else if(type == idNetworkConnector::Connect_Put)
		reply = manager->put(req, data);
	else if(type == idNetworkConnector::Connect_Delete)
		reply = manager->deleteResource(req);
	else
		reply = manager->get(req);

#ifdef _DBG
	qDebug() << "request -> " << u;
#endif
	connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
	if(!reply->isFinished())
		loop.exec(QEventLoop::ExcludeUserInputEvents);
	if(!reply->isFinished())
	{
		reply->abort();
		reply->deleteLater();
		return ret;
	}

	statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
	if(statusCode == 302 || statusCode == 301) // redirection
	{
		u = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
		qDebug() << "redirect -> " << u;
		if(!u.isValid())
		{
			if(redirect)
			{
				goto __Redirection;
			}
			else
			{
				has_redirect = true;
				goto __Response;
			}
		}
	}

__Response:
	if(r)
	{
		QByteArray data;
		if(!has_redirect)
		{
			data = reply->readAll();
			QByteArray b;
			ok = true;
			QString encoding = reply->rawHeader("Content-Encoding");
			if(encoding == "gzip")
			{
				if(id::ungzip(&b, data) != 0)
				{
					//qWarning() << "[Warning]: Ungzip error -> " << u;
					ok = false;
				}
			}
			else if(encoding == "deflate")
			{
				if(id::unz(&b, data) != 0)
				{
					//qWarning() << "[Warning]: Unz error -> " << u;
					ok = false;
				}
			}
			*r = ok ? b : data;
		}
		else
		{
			*r = u.toEncoded();
		}
#ifdef _DBG
		//qDebug() << *r;
		qDebug() << "reply -> " << r->length();
#endif
	}

	ret = reply->error();
	if(type == idNetworkConnector::Connect_Post)
		qDebug() << "[Debug]: POST " << statusCode << " : " << u.toString() << "(" + data + ")";
	else
		qDebug() << "[Debug]: GET " << statusCode << " : " << u.toString();

	reply->deleteLater();

	return ret;
}

QByteArray idNetworkConnector::MakePostData(const QVariantMap &map)
{
	QByteArray r;

	ID_CONST_FOREACH(QVariantMap, map)
	{
		r += itor.key() + "=" + itor.value().toByteArray().toPercentEncoding();
		if(itor + 1 != map.constEnd())
			r += "&";
	}
	//qDebug() <<r;
	return r;
}

int idNetworkConnector::SyncRequest_thread(const QString &url, const QList<QPair<QByteArray, QByteArray> > &querys, const QByteArray &data, int type, const QVariant &headers, QByteArray *r, bool redirect)
{
	idNetworkAccessManager manager;
	QNetworkReply *reply;
	QUrl u;
	int ret;
	bool ok;
	int statusCode;
	bool has_redirect;

	reply = 0;
	ret = -1;
	has_redirect = false;
	u.setUrl(url);
	if(!querys.isEmpty())
	{
		u.setEncodedQueryItems(querys);
	}

	QEventLoop loop;
	QNetworkRequest req;
	connect(qApp, SIGNAL(aboutToQuit()), &loop, SLOT(quit()));

	if(!headers.isNull())
	{
		if(headers.canConvert<QVariantList>())
			SetRequestHeaders(&req, headers.toList());
		else if(headers.canConvert<QVariantMap>())
			SetRequestHeaders(&req, headers.toMap());
	}

__Redirection:
	req.setUrl(u);
	if(type == idNetworkConnector::Connect_Post)
		reply = manager.post(req, data);
	else if(type == idNetworkConnector::Connect_Put)
		reply = manager.put(req, data);
	else if(type == idNetworkConnector::Connect_Delete)
		reply = manager.deleteResource(req);
	else
		reply = manager.get(req);

#ifdef _DBG
	qDebug() << "request -> " << u;
#endif
	connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
	if(!reply->isFinished())
		loop.exec(QEventLoop::ExcludeUserInputEvents);
	if(!reply->isFinished())
	{
		reply->abort();
		reply->deleteLater();
		return ret;
	}

	statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
	if(statusCode == 302 || statusCode == 301) // redirection
	{
		u = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
		qDebug() << "redirect -> " << u;
		if(!u.isValid())
		{
			if(redirect)
			{
				goto __Redirection;
			}
			else
			{
				has_redirect = true;
				goto __Response;
			}
		}
	}

__Response:
	if(r)
	{
		QByteArray data;
		if(!has_redirect)
		{
			data = reply->readAll();
			QByteArray b;
			ok = true;
			QString encoding = reply->rawHeader("Content-Encoding");
			if(encoding == "gzip")
			{
				if(id::ungzip(&b, data) != 0)
				{
					//qWarning() << "[Warning]: Ungzip error -> " << u;
					ok = false;
				}
			}
			else if(encoding == "deflate")
			{
				if(id::unz(&b, data) != 0)
				{
					//qWarning() << "[Warning]: Unz error -> " << u;
					ok = false;
				}
			}
			*r = ok ? b : data;
		}
		else
		{
			*r = u.toEncoded();
		}
#ifdef _DBG
		//qDebug() << *r;
		qDebug() << "reply -> " << r->length();
#endif
	}
	ret = reply->error();
	if(type == idNetworkConnector::Connect_Post)
		qDebug() << "[Debug]: POST " << statusCode << " : " << u.toString() << "(" + data + ")";
	else
		qDebug() << "[Debug]: GET " << statusCode << " : " << u.toString();

	reply->deleteLater();

	return ret;
}

