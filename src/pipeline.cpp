#include "pipeline.h"

#include <QApplication>
#include <QDebug>
#include <QNetworkReply>
#include <QTimer>
#include <QThread>
#include <QEventLoop>
#ifndef _SIMULATOR
#include <MNotification>
#include <MRemoteAction>
#endif

#include "id_std.h"
#include "utility.h"
#include "networkmanager.h"
#include "qmlapplicationviewer.h"

extern QmlApplicationViewer *qml_viewer;
namespace id
{
	extern void create_qml_viewer();
}

class idSyncCheckThread : public QThread
{
	//Q_OBJECT

	public:
		explicit idSyncCheckThread(QObject *parent)
			: QThread(parent),
			m_pipeline(static_cast<idPipeline *>(parent)),
			m_manager(0),
			m_interval(idUtility::Instance()->GetSetting<int>("chat/sync_background") * 1000)
		{
			setObjectName("idSyncCheckThread");
		}

		virtual ~idSyncCheckThread()
		{
			ID_QOBJECT_DESTROY_DBG
		}

		virtual void run()
		{
			while(1)
			{
				if(Handle()) Response();
				QThread::msleep(m_interval);
			}
		}

public Q_SLOTS:
    void Restart(Priority priority = IdlePriority)
		{
			if(isRunning())
				terminate();
			QThread::start(priority);
		}
    void start(Priority priority = IdlePriority)
		{
			QThread::start(priority);
		}
		void quit()
		{
			if(m_manager)
			{
				m_manager->deleteLater();
				m_manager = 0;
			}
			QThread::quit();
		}
		void terminate()
		{
			if(m_manager)
			{
				m_manager->deleteLater();
				m_manager = 0;
			}
			QThread::terminate();
		}

	private:
		bool Handle()
		{
			QNetworkReply *reply;
			qint64 ts;
			bool ret;

			ret = false;
			if(!id::network_online())
			{
				qDebug() << "[Debug]: network is offline.";
				return ret;
			}

			if(!m_pipeline->IsValid())
				return ret;
			if(!m_manager)
				m_manager = new idNetworkAccessManager(this);

			const QString Fmt("https://webpush.wx.qq.com/cgi-bin/mmwebwx-bin/synccheck?skey=%1&sid=%2&uin=%3&deviceid=%4&synckey=%5&r=%6&_=%7");
			ts = QDateTime::currentMSecsSinceEpoch();
			QNetworkRequest req(Fmt.arg(m_pipeline->tLoginInfo["skey"].toString()).arg(m_pipeline->tLoginInfo["wxsid"].toString()).arg(m_pipeline->tLoginInfo["wxuin"].toString()).arg(m_pipeline->tLoginInfo["deviceId"].toString()).arg(m_pipeline->sSyncKey).arg(ts).arg(ts));
			QEventLoop loop;
			connect(qApp, SIGNAL(aboutToQuit()), &loop, SLOT(quit()));
			reply = m_manager->get(req);
			connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
			if(!reply->isFinished())
				loop.exec(QEventLoop::ExcludeUserInputEvents);
			if(!reply->isFinished())
			{
				reply->abort();
				reply->deleteLater();
				return ret;
			}

			qDebug()<<req.url()<<reply->readAll();
			ret = reply->error() == QNetworkReply::NoError;
			reply->deleteLater();
			return ret;
		}

		void Response()
		{
		}

	private:
		idPipeline *m_pipeline;
		QNetworkAccessManager *m_manager;
		int m_interval;

		friend class idPipeline;
};
idPipeline::idPipeline(QObject *parent)
	: 
#ifndef _SIMULATOR
		QDBusAbstractAdaptor
#else
		QObject
#endif
(parent),
	m_thread(0)
{
	setObjectName("idPipeline");
}

idPipeline::~idPipeline()
{
	ID_QOBJECT_DESTROY_DBG
	StopCheck();
	//ClearNotifications();
}

void idPipeline::ShowNotification(const QString &title, const QString &message)
{
	ClearNotifications();
	AddNotification(title, message);
}

void idPipeline::AddNotification(const QString &title, const QString &message)
{
#ifndef _SIMULATOR
	MNotification notification(ID_PKG, title, message);
	MRemoteAction action("com." ID_DEV "." ID_PKG, "/com/" ID_DEV "/" ID_PKG, "com." ID_DEV "." ID_PKG, "ShowGUI");
	notification.setAction(action);
	notification.publish();
#else
	qDebug() << "AddNotification:" << title << message;
#endif
}

void idPipeline::ClearNotifications()
{
#ifndef _SIMULATOR
	QList<MNotification *> activeNotifications = MNotification::notifications();
	QMutableListIterator<MNotification *> i(activeNotifications);
	while (i.hasNext()) {
		MNotification *notification = i.next();
		if (notification->eventType() == ID_PKG)
			notification->remove();
	}
#else
	qDebug() << "ClearNotification";
#endif
}

void idPipeline::ActivateWindow()
{
	if(qml_viewer)
	{
		qDebug() << "Activate window";
		qml_viewer->showExpanded();
		qml_viewer->activateWindow();
	}
}

void idPipeline::DeactivateWindow()
{
	if(qml_viewer)
	{
		qDebug() << "Deactivate window";
		qml_viewer->hide();
	}
}

void idPipeline::CreateWindow()
{
	if(!qml_viewer)
	{
		qDebug() << "Create window";
		id::create_qml_viewer();
	}
}

void idPipeline::DestroyWindow()
{
	if(qml_viewer)
	{
		qDebug() << "Destroy window";
		qml_viewer->close();
	}
}

void idPipeline::ShowGUI()
{
#ifdef _DBG
	if(idUtility::Instance()->RunMode() == idUtility::RunMode_Close_Window)
		StopCheck();
#endif
	if(qml_viewer)
		ActivateWindow();
	else
		CreateWindow();
}

void idPipeline::QmlViewerDestroyed()
{
	qml_viewer = 0;
	ClearNotifications();
#ifdef _DBG
	if(idUtility::Instance()->RunMode() == idUtility::RunMode_Close_Window
#if 1
			&& 0
#endif
			)
		SyncCheck();
#endif
}

idPipeline * idPipeline::Create(QObject *parent)
{
	static idPipeline *pipeline = 0;
	if(!pipeline)
	{
		pipeline = new idPipeline(parent);
		id::register_to_qt_dbus("com." ID_DEV "." ID_PKG, "/com/" ID_DEV "/" ID_PKG, parent);
	}
	return pipeline;
}

QVariant idPipeline::GetLoginData() const
{
	QVariant r;
	if(!tLoginInfo.isEmpty() || !tUserInfo.isEmpty())
	{
		QVariantMap m;
		m.insert("user_info", tUserInfo);
		m.insert("login_info", tLoginInfo);
		r.setValue(m);
	}
	//	qDebug()<<"get->"<<r;
	return r;
}

void idPipeline::SetLoginData(const QVariant &data)
{
	//	qDebug()<<"set->"<<data <<data.canConvert<QVariantMap>();
	if(data.canConvert<QVariantMap>())
	{
		QVariantMap m = data.toMap();

		if(m.contains("user_info"))
			tUserInfo = m["user_info"].toMap();
		else
			tUserInfo.clear();
		if(m.contains("login_info"))
			tLoginInfo = m["login_info"].toMap();
		else
			tLoginInfo.clear();
	}
	else
	{
		/*
			 tUserInfo.clear();
			 tLoginInfo.clear();
			 */
	}
}

void idPipeline::Quit()
{
	QApplication::quit();
}

int idPipeline::RunMode() const
{
	return static_cast<int>(idUtility::Instance()->RunMode());
}

void idPipeline::SyncCheck()
{
	if(!IsValid())
		return;
	if(!m_thread)
		m_thread = new idSyncCheckThread(this);
	qDebug() << "[Debug]: Sync check thread start.";
	m_thread->Restart();
}

void idPipeline::StopCheck()
{
	if(m_thread && m_thread->isRunning())
	{
		m_thread->terminate();
		qDebug() << "[Debug]: Sync check thread stop.";
	}
}

bool idPipeline::IsValid() const
{
	static QStringList Keys(QStringList() << "skey" << "wxsid" << "wxuin" << "pass_ticket" << "webwx_data_ticket" << "webwx_auth_ticket");

	ID_CONST_FOREACH(QStringList, Keys)
	{
		if(!tLoginInfo.contains(*itor))
			return false;
		QString s = tLoginInfo[*itor].toString();
		if(s.isEmpty())
			return false;
	}
	return true;
}

void idPipeline::SetSyncKey(const QVariant &v)
{
	if(v.canConvert<QString>())
	{
		sSyncKey = v.toString();
	}
	else
	{
		QStringList sl;
		QVariantMap m = v.toMap();
		QVariantList l = m["List"].toList();
		ID_CONST_FOREACH(QVariantList, l)
		{
			QVariantMap e = itor->toMap();
			sl.push_back(e["Key"].toString() + "_" + e["Val"].toString());
		}
		sSyncKey = sl.join("|");
	}
	//qDebug() << sSyncKey << v;
}



namespace id
{
	bool register_to_qt_dbus(const QString &service, const QString &path, QObject *obj)
	{
#ifndef _SIMULATOR
		QDBusConnection conn = QDBusConnection::sessionBus();
		if(!conn.registerService(service))
			qDebug() << "QtDBus -> " << conn.lastError();
		else
		{
			if(!conn.registerObject(path, obj))
				qDebug() << "QtDBus -> " << conn.lastError();
			else
				return true;
		}
#endif
		return false;
	}
}

void idPipeline::Boot()
{
	QProcess::startDetached(qApp->applicationFilePath(), QStringList());
}
