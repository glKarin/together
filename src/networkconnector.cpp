#include "networkconnector.h"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDeclarativeEngine>
#include <QDateTime>
#include <QStringList>
#include <QDebug>

#include "id_std.h"
#include "utility.h"

	idNetworkConnector::idNetworkConnector(QObject *parent)
: QObject(parent)
{
	setObjectName("idNetworkConnector");
}

idNetworkConnector::~idNetworkConnector()
{
	oEngine = 0;
}

QString idNetworkConnector::Request(const QString &url, const QString &field, const QByteArray &data, int type, const QVariant &headers)
{
	QNetworkAccessManager *manager;
	QNetworkReply *reply;
	QString r;

	reply = 0;
	manager = Manager();
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
	if(type == idNetworkConnector::Connect_Put)
		reply = manager->put(req, data);
	if(type == idNetworkConnector::Connect_Delete)
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

void idNetworkConnector::SetEngine(QDeclarativeEngine *engine)
{
	oEngine = engine;
}

QDeclarativeEngine * idNetworkConnector::Engine()
{
	return oEngine;
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

QNetworkAccessManager * idNetworkConnector::Manager()
{
	if(!oEngine)
		return 0;

	return oEngine->networkAccessManager();
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
