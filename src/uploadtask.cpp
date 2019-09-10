#include "uploadtask.h"

#include <QFile>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QDateTime>
#include <QCryptographicHash>
#include <QFileInfo>
#include <QDebug>

#include "serializer.h"
#include "parser.h"

#include "id_std.h"

#define PART_CHUNK_SIZE 524288 //(1024 * 512)

unsigned int idUploadTask::_id = 0;

	idUploadTask::idUploadTask(QObject *parent)
	: idTransferTask_base(parent),
	m_pos(0),
	m_size(0),
	m_part(-1),
	m_total(0),
	m_fileSize(0),
	m_id(0)
{
	SetType(idTransferTask_base::Type_Upload);
	setObjectName("idUploadTask");
}

idUploadTask::~idUploadTask()
{
	ID_QOBJECT_DESTROY_DBG
}

void idUploadTask::Transfer()
{
	if(m_status != idTransferTask_base::Status_Ready)
		return;
	if(!Begin())
	{
		SetStatus(idTransferTask_base::Status_Error);
		SetError(-1);
		emit finished(m_error);
		return;
	}

	SetStatus(idTransferTask_base::Status_Doing);
	emit started();

	Send();
}

void idUploadTask::Retransfer()
{
	Abort();

	SetStatus(idTransferTask_base::Status_Ready);

	Transfer();
}

void idUploadTask::finished_slot()
{
	QNetworkReply *reply;
	int statusCode;
	bool redirect;
	QUrl url;

	redirect = false;
	reply = dynamic_cast<QNetworkReply *>(sender());
	if(reply != m_reply)
	{
		if(reply->isRunning())
			reply->abort();
		reply->deleteLater();
		return;
	}

	SetError(reply->error());
	if(reply->error() == QNetworkReply::NoError)
	{
		statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
		if(statusCode == 302 || statusCode == 301) // redirection
		{
			url = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
			qDebug() << "redirect -> " << url;
			if(!url.isValid())
			{
				redirect = true;
			}
		}
		else
		{
			QByteArray data = reply->readAll();
			QByteArray r;
			QString encoding = reply->rawHeader("Content-Encoding");
			if(encoding == "gzip")
			{
				if(id::ungzip(&r, data) != 0)
					r = data;
			}
			else if(encoding == "deflate")
			{
				if(id::unz(&r, data) != 0)
					r = data;
			}
			else
			{
				r = data;
			}
			SetResponseData(r);
		}
	}

	if(!redirect)
	{
		if(m_part == m_total - 1)
		{
			SetProgress(1.0);
			End();
		}
		else
		{
			m_reply->deleteLater();
			Send(1);
		}
	}
	else
	{
		m_reply->deleteLater();
		Send();
	}
}

void idUploadTask::updateProgress_slot(qint64 bytes, qint64 total)
{
	QNetworkReply *reply;

	reply = dynamic_cast<QNetworkReply *>(sender());
	if(reply != m_reply)
	{
		if(reply->isRunning())
			reply->abort();
		reply->deleteLater();
		return;
	}

	if(bytes == 0 && total == 0)
		return;

	//qDebug()<<"U"<<bytes<<total;
	if(total > 0)
		SetProgress(qreal(m_pos + bytes) / qreal(m_fileSize));
	else
		SetProgress(0.0);
	SetReadBytes(m_pos + bytes);
	SetTotalBytes(m_fileSize);
}

void idUploadTask::MakePostData(QByteArray &r, QMap<QByteArray, QByteArray> &h)
{
	const QByteArray boundaryValue(QCryptographicHash::hash(QByteArray().append(QByteArray::number(qulonglong((QDateTime::currentMSecsSinceEpoch() ^ qrand()) ^ 2014)).toBase64()), QCryptographicHash::Md5).toHex().mid(8, 16));
	const QByteArray boundary("----WebKitFormBoundary" + boundaryValue);
	const QFileInfo info(m_filePath);
	QByteArray fileName;
	QByteArray mime;
	int tz;
	QJson::Serializer serializer;
	QVariantMap uploadmediarequest;
	QVariantMap map;

	tz = id::get_time_zone();
	mime.append(id::get_mime_type(info.suffix()));
	if(mime.isEmpty())
		mime.append("application/octet-stream");
	m_file->seek(m_pos);
	QByteArray data = m_file->read(m_size);
	map.insert("Uin", m_postParams["Uin"]);
	map.insert("Sid", m_postParams["Sid"]);
	map.insert("Skey", m_postParams["Skey"]);
	map.insert("DeviceID", m_postParams["DeviceID"]);
	uploadmediarequest.insert("UploadType", 2);
	uploadmediarequest.insert("BaseRequest", map);
	uploadmediarequest.insert("ClientMediaId", m_msgId);
	uploadmediarequest.insert("TotalLen", m_fileSize);
	uploadmediarequest.insert("StartPos", 0);
	uploadmediarequest.insert("DataLen", m_fileSize);
	uploadmediarequest.insert("MediaType", 4);
	uploadmediarequest.insert("FromUserName", m_postParams["FromUserName"]);
	uploadmediarequest.insert("ToUserName", QByteArray().append(m_uname));
	uploadmediarequest.insert("FileMd5", QCryptographicHash::hash(data, QCryptographicHash::Md5).toHex());

	fileName.append(info.fileName());
	r.clear();
	QByteArray mediaType = mime.split('/')[0];
	if(mime == "image/gif")
		mediaType = "doc";
	else if(mediaType == "image")
		mediaType = "pic";
	else if(mediaType == "video");
	else
		mediaType = "doc";

	r.clear();
	r
		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"id\"")
		.append("\r\n")
		.append("\r\n")
		.append("WU_FILE_" + QByteArray::number(m_id))
		.append("\r\n")

		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"name\"")
		.append("\r\n")
		.append("\r\n")
		.append(fileName)
		.append("\r\n")

		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"type\"")
		.append("\r\n")
		.append("\r\n")
		.append(mime)
		.append("\r\n")

		// Mon Aug 05 2019 21:35:11 GMT+0800 (China Standard Time)
		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"lastModifiedDate\"")
		.append("\r\n")
		.append("\r\n")
		.append(QByteArray().append(QDateTime::currentDateTime().toString("ddd MMM dd yyyy hh:mm:ss") + " GMT" + QByteArray().append(QString("%1%2").arg(tz >= 0 ? '+' : '-')
#if 0
						.arg(tz, 2, 10, '0')
#else
						.arg(tz >= 10 ? QString::number(tz) : "0" + QString::number(tz))
#endif
						) + "00"))
		.append("\r\n")

		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"size\"")
		.append("\r\n")
		.append("\r\n")
		.append(QByteArray::number(m_fileSize))
		.append("\r\n")
		;

		if(m_total > 1)
		{
			r
		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"chunks\"")
		.append("\r\n")
		.append("\r\n")
		.append(QByteArray::number(m_total))
		.append("\r\n")

		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"chunk\"")
		.append("\r\n")
		.append("\r\n")
		.append(QByteArray::number(m_part))
		.append("\r\n")
		;
		}

		r
		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"mediatype\"")
		.append("\r\n")
		.append("\r\n")
		.append(mediaType)
		.append("\r\n")

		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"uploadmediarequest\"")
		.append("\r\n")
		.append("\r\n")
		.append(serializer.serialize(uploadmediarequest))
		.append("\r\n")

		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"webwx_data_ticket\"")
		.append("\r\n")
		.append("\r\n")
		.append(m_postParams["webwx_data_ticket"])
		.append("\r\n")

		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"pass_ticket\"")
		.append("\r\n")
		.append("\r\n")
		.append(m_postParams["pass_ticket"])
		.append("\r\n")

		.append("--")
		.append(boundary)
		.append("\r\n")
		.append("Content-Disposition: form-data; name=\"filename\"; filename=\"" + fileName + "\"")
		.append("\r\n")
		.append("Content-Type: " + mime)
		.append("\r\n")
		.append("\r\n")
		.append(data)
		.append("\r\n")

		.append("--")
		.append(boundary)
		.append("--")
		;

	h.insert("Content-Type", "multipart/form-data; boundary=" + boundary);
	h.insert("Sec-Fetch-Mode", "cors");
	//h.insert("Content-Length", QByteArray::number(r.length()));
	//qDebug() << r;
}

bool idUploadTask::Begin()
{
	QNetworkReply *reply;

	if(m_remoteUrl.isEmpty() || m_filePath.isEmpty())
		return false;
	if(m_status != idTransferTask_base::Status_Ready)
		return false;
	if(!QFile::exists(m_filePath))
	{
		qWarning() << "[Error]: File is not exists -> " << m_filePath;
		return false;
	}
	if(m_file)
	{
		if(m_file->isOpen())
			m_file->close();
	}
	else
		m_file = new QFile;
	m_file->setFileName(m_filePath);
	if(!m_file->open(QIODevice::ReadOnly))
	{
		delete m_file;
		m_file = 0;
		return false;
	}
	if(m_reply)
	{
		reply = m_reply;
		m_reply = 0;
		if(reply->isRunning())
			reply->abort();
		reply->deleteLater();
	}
	m_fileSize = m_file->size();
	m_pos = 0;
	m_size = (int)qMin((qint64)PART_CHUNK_SIZE, m_fileSize);
	m_part = 0;
	m_total = m_fileSize / m_size + (m_fileSize % m_size ? 1 : 0);
	SetResponseData();
	m_id = _id++;
	qDebug() << "[Debug]: Begin upload: " << m_filePath << " -> " << m_remoteUrl << " Upload Id -> " << _id << " Chunks -> " << m_total;
	return true;
}

void idUploadTask::End()
{
	QNetworkReply *reply;
	bool full;

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

	full = (m_total == m_part + 1);
	SetStatus(full && m_error == 0 && !m_mediaId.isEmpty() ? idTransferTask_base::Status_Done : idTransferTask_base::Status_Error);
	emit finished(m_error);

	qDebug() << "[Debug]: End upload: " << m_filePath << " -> " << (m_error == 0 ? "success" : "error");
}

void idUploadTask::SetPostParams(const QVariantMap &params)
{
	m_postParams.clear();
	ID_CONST_FOREACH(QVariantMap, params)
	{
		m_postParams.insert(QByteArray().append(itor.key()), itor.value().toByteArray());
	}
}

QMap<QByteArray, QByteArray> idUploadTask::PostParams() const
{
	return m_postParams;
}

QByteArray idUploadTask::ResponseData() const
{
	return m_responseData;
}

QVariant idUploadTask::ToVariant(const QString &name)
{
	QVariant r;

	if(name.isEmpty())
	{
		QVariantMap map = idTransferTask_base::ToVariant(name).toMap();
		map.insert("UNAME", m_uname);
		r.setValue(map);
	}
	else
	{
		if(name == "UNAME")
			r.setValue(m_uname);
		else
			r = idTransferTask_base::ToVariant(name);
	}
	return r;
}

QString idUploadTask::Uname() const
{
	return m_uname;
}

void idUploadTask::SetUname(const QString &value)
{
	if(m_status != idTransferTask_base::Status_Ready)
		return;
	if(m_uname != value)
	{
		m_uname = value;
		emit unameChanged(m_uname);
	}
}

bool idUploadTask::NextParkChunk()
{
	qint64 next_pos;

	if(m_status != idTransferTask_base::Status_Doing)
		return false;

	next_pos = m_pos + m_size;
	if(next_pos < m_fileSize)
	{
		m_pos = next_pos;
		m_size = (int)qMin((qint64)PART_CHUNK_SIZE, m_fileSize - m_pos);
		m_part++;
		qDebug() << "Next chunk: pos -> " << m_pos << " size -> " << m_size << "(" << m_part << ", " << m_total << ")";
		return true;
	}
	return false;
}

void idUploadTask::SetResponseData(const QByteArray &data)
{
	QJson::Parser parser;
	bool ok;

	m_responseData = data;
	if(!m_responseData.isEmpty())
	{
		//qDebug()<<m_responseData;
		QVariant r = parser.parse(m_responseData, &ok);
		if(ok)
		{
			QVariantMap map = r.toMap();
			QVariantMap res = map["BaseResponse"].toMap();
			if(res["Ret"].toInt() == 0)
			{
				SetMediaId(map["MediaId"].toString());
			}
			else
			{
				SetMediaId(QString());
			}
		}
		else
		{
			SetMediaId(QString());
		}
	}
	else
	{
		SetMediaId(QString());
	}
}

void idUploadTask::Send(int p)
{
	QByteArray data;
	QMap<QByteArray, QByteArray> headers;

	if(p)
		NextParkChunk();
	MakePostData(data, headers);

	m_reply = Request(m_remoteUrl, data, idTransferTask_base::RequestType_Post, headers);
	connect(m_reply, SIGNAL(finished()), this, SLOT(finished_slot()));
	connect(m_reply, SIGNAL(uploadProgress(qint64, qint64)), this, SLOT(updateProgress_slot(qint64, qint64)));
}
