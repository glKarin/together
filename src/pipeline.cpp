#include "pipeline.h"

#include <QApplication>
#include <QDebug>
#include <QNetworkReply>
#include <MNotification>
#include <MRemoteAction>

#include "id_std.h"
#include "utility.h"
#include "networkmanager.h"
#include "qmlapplicationviewer.h"

extern QmlApplicationViewer *qml_viewer;
namespace id
{
	extern void create_qml_viewer();
}

idPipeline::idPipeline(QObject *parent)
	: QDBusAbstractAdaptor(parent)
{
	setObjectName("idPipeline");
}

idPipeline::~idPipeline()
{
	ClearNotifications();
}

void idPipeline::ShowNotification(const QString &title, const QString &message)
{
	ClearNotifications();
	AddNotification(title, message);
}

void idPipeline::AddNotification(const QString &title, const QString &message)
{
#ifdef _HARMATTAN
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
#ifdef _HARMATTAN
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

void idPipeline::DestoryWindow()
{
	if(qml_viewer)
	{
		qDebug() << "Destroy window";
		qml_viewer->close();
	}
}

void idPipeline::ShowGUI()
{
	if(qml_viewer)
		ActivateWindow();
	else
		CreateWindow();
}

void idPipeline::QmlViewerDestroyed()
{
	qml_viewer = 0;
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

QNetworkAccessManager * idPipeline::NetworkManager()
{
	extern idDeclarativeNetworkAccessManagerFactory factory;
	if(!oManager)
	{
		oManager = factory.create(this);
	}
	return oManager;
}

void idPipeline::finishedSLOT(QNetworkReply *reply)
{
	int err;

	err = reply->error();
	if(err == QNetworkReply::NoError)
	{
		QByteArray data = reply->readAll();
		qDebug() << "Sync data -> " << data;
		// handle json with libqjson
	}
	else
		qDebug() << "Sync on background error -> " << reply->errorString();

	reply->deleteLater();
	QTimer::singleShot(idUtility::Instance()->GetSetting<int>("chat/sync_interval_background"), this, SLOT(SyncCheck()));
}

void idPipeline::SyncCheck()
{
	QNetworkAccessManager *manager;
	qint64 ts;
	const QString Fmt("https://webpush.wx.qq.com/cgi-bin/mmwebwx-bin/synccheck?skey=%1&sid=%2&uin=%3&deviceid=%4&synckey=%5&r=%6&_=%7");

	if(!IsValid())
		return;
	manager = NetworkManager();
	if(!manager)
		return;

	ts = QDateTime::currentMSecsSinceEpoch();
	QNetworkRequest req(Fmt.arg(tLoginInfo["skey"].toString()).arg(tLoginInfo["wxsid"].toString()).arg(tLoginInfo["wxuin"].toString()).arg(tLoginInfo["deviceId"].toString()).arg(sSyncKey).arg(ts).arg(ts));
	manager->get(req);
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
		return false;
	}
}
