#include "transfertask_base.h"

#include <QFile>
#include <QDebug>
#include <QDeclarativeEngine>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>

#include "qmlapplicationviewer.h"

extern QmlApplicationViewer *qml_viewer;

#include "id_std.h"

	idTransferTask_base::idTransferTask_base(QObject *parent)
	: QObject(parent),
	m_file(0),
	m_progress(0.0),
	m_status(idTransferTask_base::Status_Ready),
	m_error(0),
	m_msgType(0),
	m_readBytes(0),
	m_totalBytes(0),
	m_reply(0)
{
	setObjectName("idTransferTask_base");
}

idTransferTask_base::~idTransferTask_base()
{
	//ID_QOBJECT_DESTROY_DBG
	Abort();
}

qreal idTransferTask_base::Progress() const
{
	return m_progress;
}

idTransferTask_base::idStatus_e idTransferTask_base::Status() const
{
	return m_status;
}

idTransferTask_base::idType_e idTransferTask_base::Type() const
{
	return m_type;
}

int idTransferTask_base::Error() const
{
	return m_error;
}

QString idTransferTask_base::FilePath() const
{
	return m_filePath;
}

QString idTransferTask_base::RemoteUrl() const
{
	return m_remoteUrl;
}

QString idTransferTask_base::MediaId() const
{
	return m_mediaId;
}

QString idTransferTask_base::MsgId() const
{
	return m_msgId;
}

QString idTransferTask_base::SessionId() const
{
	return m_sessionId;
}

int idTransferTask_base::MsgType() const
{
	return m_msgType;
}

qint64 idTransferTask_base::ReadBytes() const
{
	return m_readBytes;
}

qint64 idTransferTask_base::TotalBytes() const
{
	return m_totalBytes;
}

void idTransferTask_base::SetFilePath(const QString &value)
{
	if(m_status != idTransferTask_base::Status_Ready)
		return;
	if(m_filePath != value)
	{
		m_filePath = value;
		emit filePathChanged(m_filePath);
	}
}

void idTransferTask_base::SetRemoteUrl(const QString &value)
{
	if(m_status != idTransferTask_base::Status_Ready)
		return;
	if(m_remoteUrl != value)
	{
		m_remoteUrl = value;
		emit remoteUrlChanged(m_remoteUrl);
	}
}

void idTransferTask_base::SetType(idTransferTask_base::idType_e value)
{
	if(m_status != idTransferTask_base::Status_Ready)
		return;
	if(m_type != value)
	{
		m_type = value;
		emit typeChanged(m_type);
	}
}

void idTransferTask_base::SetMediaId(const QString &value)
{
	if(m_mediaId != value)
	{
		m_mediaId = value;
		emit mediaIdChanged(m_mediaId);
	}
}

void idTransferTask_base::SetMsgId(const QString &value)
{
	if(m_status != idTransferTask_base::Status_Ready)
		return;
	if(m_msgId != value)
	{
		m_msgId = value;
		emit msgIdChanged(m_msgId);
	}
}

void idTransferTask_base::SetSessionId(const QString &value)
{
	if(m_status != idTransferTask_base::Status_Ready)
		return;
	if(m_sessionId != value)
	{
		m_sessionId = value;
		emit sessionIdChanged(m_sessionId);
	}
}

void idTransferTask_base::SetMsgType(int value)
{
	if(m_status != idTransferTask_base::Status_Ready)
		return;
	if(m_msgType != value)
	{
		m_msgType = value;
		emit msgTypeChanged(m_msgType);
	}
}

void idTransferTask_base::SetReadBytes(qint64 value)
{
	if(m_readBytes != value)
	{
		m_readBytes = value;
		emit readBytesChanged(m_readBytes);
	}
}

void idTransferTask_base::SetTotalBytes(qint64 value)
{
	if(m_totalBytes != value)
	{
		m_totalBytes = value;
		emit totalBytesChanged(m_totalBytes);
	}
}

void idTransferTask_base::SetProgress(qreal value)
{
	qreal f;

	f = id::fixed_float(value, 2);
	if(m_progress != f)
	{
		m_progress = f;
		emit progressChanged(m_progress);
	}
}

void idTransferTask_base::SetError(int value)
{
	if(m_error != value)
	{
		m_error = value;
		emit errorChanged(m_error);
	}
}

void idTransferTask_base::SetStatus(idTransferTask_base::idStatus_e value)
{
	if(m_status != value)
	{
		m_status = value;
		emit statusChanged(m_status);
	}
}

QNetworkAccessManager * idTransferTask_base::NetworkManager()
{
	if(!qml_viewer)
		return 0;
	return qml_viewer->engine()->networkAccessManager();
}

QNetworkReply * idTransferTask_base::Request(const QString &url, const QByteArray &data, idTransferTask_base::idRequestType_e type, const QMap<QByteArray, QByteArray> &headers)
{
	QNetworkAccessManager *manager;
	QNetworkReply *reply;

	manager = NetworkManager();
	if(!manager)
		return 0;
	
	QNetworkRequest req(url);
	for(QMap<QByteArray, QByteArray>::const_iterator itor = headers.constBegin();
			itor != headers.constEnd(); ++itor)
	{
		req.setRawHeader(itor.key(), itor.value());
	}

	if(type == idTransferTask_base::RequestType_Post)
		reply = manager->post(req, data);
	else
		reply = manager->get(req);

	return reply;
}

void idTransferTask_base::Abort()
{
	QNetworkReply *reply;

	if(m_file)
	{
		m_file->flush();
		m_file->close();
		delete m_file;
		m_file = 0;
	}
	if(m_reply)
	{
		reply = m_reply;
		m_reply = 0;
		if(reply->isRunning())
			reply->abort();
		reply->deleteLater();
	}
	SetStatus(idTransferTask_base::Status_Error);
}

QVariant idTransferTask_base::ToVariant(const QString &name)
{
	QVariant r;

	if(name.isEmpty())
	{
		QVariantMap map;
		map.insert("MEDIA_ID", m_mediaId);
		map.insert("TYPE", static_cast<int>(m_type));
		map.insert("URL", m_remoteUrl);
		map.insert("FILE_PATH", m_filePath);
		map.insert("STATUS", static_cast<int>(m_status));
		map.insert("MSG_ID", m_msgId);
		map.insert("SESSION", m_sessionId);
		map.insert("MSG_TYPE", m_msgType);
		r.setValue(map);
	}
	else
	{
		if(name == "MEDIA_ID")
			r.setValue(m_mediaId);
		else if(name == "TYPE")
			r.setValue(static_cast<int>(m_type));
		else if(name == "URL")
			r.setValue(m_remoteUrl);
		else if(name == "FILE_PATH")
			r.setValue(m_filePath);
		else if(name == "STATUS")
			r.setValue(static_cast<int>(m_status));
		else if(name == "MSG_ID")
			r.setValue(m_msgId);
		else if(name == "SESSION")
			r.setValue(m_sessionId);
		else if(name == "MSG_TYPE")
			r.setValue(m_msgType);
	}
	return r;
}
