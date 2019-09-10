#include "qmlimage.h"

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDeclarativeEngine>
#include <QFile>

#include "qmlapplicationviewer.h"
#include "id_std.h"
#include "cache.h"

extern QmlApplicationViewer *qml_viewer;

idQmlImage::idQmlImage(QDeclarativeItem *parent)
	: QDeclarativeItem(parent),
	m_asynchronous(true),
	m_cache(false),
	m_fillMode(idQmlImage::Stretch),
	m_mirror(false),
	m_paintedHeight(0.0),
	m_paintedWidth(0.0),
	m_progress(0.0),
	m_smooth(true),
	m_status(idQmlImage::Null),
	m_compressed(0),
	m_reply(0)
{
	setObjectName("idQmlImage");

	setFlag(QGraphicsItem::ItemHasNoContents, false);
}

idQmlImage::~idQmlImage()
{
	ID_QOBJECT_DESTROY_DBG
	QNetworkReply *reply;

	reply = m_reply;
	m_reply = 0;
	if(reply)
	{
		if(reply->isRunning())
			reply->abort();
		reply->deleteLater();
	}
}

QUrl idQmlImage::Source() const
{
	return m_source;
}

bool idQmlImage::Asynchronous() const
{
	return m_asynchronous;
}

bool idQmlImage::Cache() const
{
	return m_cache;
}

bool idQmlImage::Mirror() const
{
	return m_mirror;
}

bool idQmlImage::Smooth() const
{
	return m_smooth;
}

idQmlImage::idStatus_e idQmlImage::Status() const
{
	return m_status;
}

idQmlImage::idFillMode_e idQmlImage::FillMode() const
{
	return m_fillMode;
}

qreal idQmlImage::PaintedHeight() const
{
	return m_paintedHeight;
}

qreal idQmlImage::PaintedWidth() const
{
	return m_paintedWidth;
}

qreal idQmlImage::Progress() const
{
	return m_progress;
}

QSize idQmlImage::SourceSize() const
{
	return m_sourceSize;
}

void idQmlImage::SetSource(const QUrl &source)
{
	if(m_source != source)
	{
		m_source = source;
		InitLoad();
		emit sourceChanged(m_source);
	}
}

void idQmlImage::SetSourceSize(const QSize &value)
{
	if(m_sourceSize != value)
	{
		m_sourceSize = value;
		update();
		emit sourceSizeChanged(m_sourceSize);
	}
}

void idQmlImage::SetSmooth(bool value)
{
	if(m_smooth != value)
	{
		m_smooth = value;
		update();
		emit smoothChanged(m_smooth);
	}
}

void idQmlImage::SetMirror(bool value)
{
	if(m_mirror != value)
	{
		m_mirror = value;
		update();
		emit mirrorChanged(m_mirror);
	}
}

void idQmlImage::SetCache(bool value)
{
	if(m_cache != value)
	{
		m_cache = value;
		emit cacheChanged(m_cache);
	}
}

void idQmlImage::SetAsynchronous(bool value)
{
	if(m_asynchronous != value)
	{
		m_asynchronous = value;
		emit asynchronousChanged(m_asynchronous);
	}
}

void idQmlImage::SetFillMode(idQmlImage::idFillMode_e value)
{
	if(m_fillMode != value)
	{
		m_fillMode = value;
		update();
		emit fillModeChanged(m_fillMode);
	}
}

void idQmlImage::SetStatus(idQmlImage::idStatus_e value)
{
	if(m_status != value)
	{
		m_status = value;
		emit statusChanged(m_status);
	}
}

void idQmlImage::SetPaintedWidth(qreal value)
{
	if(m_paintedWidth != value)
	{
		m_paintedWidth = value;
		emit paintedWidthChanged(m_paintedWidth);
	}
}

void idQmlImage::SetPaintedHeight(qreal value)
{
	if(m_paintedHeight != value)
	{
		m_paintedHeight = value;
		emit paintedHeightChanged(m_paintedHeight);
	}
}

void idQmlImage::SetProgress(qreal value)
{
	qreal f;

	f = id::fixed_float(value, 2);
	if(m_progress != f)
	{
		m_progress = value;
		emit progressChanged(m_progress);
	}
}

void idQmlImage::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
	Q_UNUSED(widget);
	Q_UNUSED(option);

	QRect itemRect(0, 0, width(), height());

	if(!m_image.isNull())
		painter->drawImage(itemRect, m_image);
}

QNetworkAccessManager * idQmlImage::Manager()
{
	if(!qml_viewer)
		return 0;

	return qml_viewer->engine()->networkAccessManager();
}


void idQmlImage::LoadImageData(bool remote)
{
	bool ok;
	QByteArray b;

	ok = true;
	if(m_compressed == 1)
	{
		if(id::ungzip(&b, m_data) != 0)
		{
			//qWarning() << "[Warning]: Ungzip error -> " << u;
			ok = false;
		}
	}
	else if(m_compressed == 2)
	{
		if(id::unz(&b, m_data) != 0)
		{
			//qWarning() << "[Warning]: Unz error -> " << u;
			ok = false;
		}
	}

	if(ok && m_compressed != 0)
		m_data = b;

	ok = m_image.loadFromData(m_data);
	if(!ok)
	{
		SetStatus(idQmlImage::Error);
		qDebug() << "[Qml]: image invalid -> " << m_source.toString();
		return;
	}

	if(m_cache && remote)
	{
		idCache::Cache(m_source.toString(), m_data);
	}
	update();
}

void idQmlImage::Init()
{
	SetStatus(idQmlImage::Null);
	SetSourceSize(QSize());
	SetProgress(0.0);
	SetPaintedWidth(0.0);
	SetPaintedHeight(0.0);

	m_data.clear();
	m_compressed = 0;
}

void idQmlImage::InitLoad()
{
	QNetworkReply *reply;

	Init();
	reply = m_reply;
	m_reply = 0;

	if(reply)
	{
		if(reply->isRunning())
			reply->abort();
		reply->deleteLater();
	}

	QString scheme = m_source.scheme();
	if(scheme.isEmpty() || scheme == "file")
		InitFromLocal();
	else if(scheme == "data")
		InitFromBase64(m_source.toString());
	else
	{
		if(m_cache)
		{
			QString path = idCache::GetCache(m_source.toString());
			if(!path.isEmpty())
			{
				InitFromLocal(path);
				return;
			}
		}
		InitFromNetwork();
	}
}

void idQmlImage::readyRead_slot()
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

	if(reply->error() == QNetworkReply::NoError)
	{
		m_data.append(reply->readAll());
	}
}

void idQmlImage::downloadProgress_slot(qint64 read, qint64 total)
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

	if(read == 0 && total == 0)
		return;

	if(total > 0)
		SetProgress(qreal(read) / qreal(total));
	else
		SetProgress(0.0);
}

void idQmlImage::finished_slot()
{
	QNetworkReply *reply;
	int statusCode;
	bool redirect;
	QUrl url;

	redirect = false;
	reply = dynamic_cast<QNetworkReply *>(sender());
	if(reply == m_reply)
	{
		m_reply = 0;
		if(reply->error() != QNetworkReply::NoError)
		{
			SetStatus(idQmlImage::Error);
		}
		else
		{
			statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
			if(statusCode == 302 || statusCode == 301) // redirection
			{
				url = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
				qDebug() << "redirect -> " << url;
				if(!url.isValid())
				{
					SetProgress(0.0);
					m_data.clear();
					redirect = true;
				}
			}
			else
			{
				SetProgress(1.0);
				QString encoding = reply->rawHeader("Content-Encoding");
				if(encoding == "gzip")
					m_compressed = 1;
				else if(encoding == "deflate")
					m_compressed = 2;
				else
					m_compressed = 0;

				LoadImageData(true);
			}
		}
	}

	reply->deleteLater();
	if(redirect)
		InitFromNetwork(url);
}

void idQmlImage::InitFromNetwork(const QUrl &url)
{
	QNetworkAccessManager *manager;

	SetStatus(idQmlImage::Loading);
	manager = Manager();
	if(!manager)
	{
		SetStatus(idQmlImage::Error);
		return;
	}

	QNetworkRequest req(url.isEmpty() ? m_source : url);

	m_reply = manager->get(req);

	connect(m_reply, SIGNAL(readyRead()), this, SLOT(readyRead_slot()));
	connect(m_reply, SIGNAL(downloadProgress(qint64, qint64)), this, SLOT(downloadProgress_slot(qint64, qint64)));
	connect(m_reply, SIGNAL(finished()), this, SLOT(finished_slot()));
}

void idQmlImage::InitFromLocal(const QString &path)
{
	QFile file(path.isEmpty() ? m_source.path() : path);
	SetStatus(idQmlImage::Loading);
	if(!file.exists())
	{
		SetStatus(idQmlImage::Error);
		return;
	}

	file.open(QIODevice::ReadOnly);
	if(!file.isOpen())
	{
		SetStatus(idQmlImage::Error);
		return;
	}

	SetProgress(0.0);
	m_data = file.readAll();
	m_compressed = 0;
	SetProgress(1.0);

	file.close();

	LoadImageData(false);
}

void idQmlImage::InitFromBase64(const QString &data)
{
	bool ok;

	QRegExp regex("^data:img/(.+);base64,(.+)");
	SetStatus(idQmlImage::Loading);
	ok = regex.exactMatch(data);
	if(regex.captureCount() < 2)
	{
		SetStatus(idQmlImage::Error);
		return;
	}
	SetProgress(0.0);
	m_data = QByteArray::fromBase64(QByteArray().append(regex.capturedTexts()[2]));
	m_compressed = 0;
	SetProgress(1.0);

	LoadImageData(false);
}

void idQmlImage::Dump(const QString &path)
{
	if(m_status == idQmlImage::Ready)
		id::file_put_contents(path, m_data);
}
