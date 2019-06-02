#ifndef _KARIN_PIPELINE_H
#define _KARIN_PIPELINE_H

#include <QtDBus>
#include <QVariant>

class QNetworkAccessManager;
class QNetworkReply;

class idPipeline : public QDBusAbstractAdaptor
{
	Q_OBJECT
		Q_CLASSINFO("D-Bus Interface", "com.karin.together")  

		Q_CLASSINFO("D-Bus Introspection",  
				"  <interface name=\"com.karin.together\">\n"  
				"    <method name=\"ActivateWindow\">\n"  
				"    </method>\n" 
				"    <method name=\"DeactivateWindow\">\n"  
				"    </method>\n" 
				"    <method name=\"CreateWindow\">\n"  
				"    </method>\n" 
				"    <method name=\"ShowGUI\">\n"  
				"    </method>\n" 
				"    <method name=\"DestoryWindow\">\n"  
				"    </method>\n" 
				"    <method name=\"Quit\">\n"  
				"    </method>\n" 
				"    <method name=\"RunMode\">\n"  
				"      <arg name=\"run_mode\" type=\"i\" direction=\"out\"/>\n" 
				"    </method>\n" 
				"  </interface>\n"  
				"")

	public:
		virtual ~idPipeline();
		static idPipeline * Create(QObject *parent);
		Q_INVOKABLE void ShowNotification(const QString &title, const QString &message);
		Q_INVOKABLE void AddNotification(const QString &title, const QString &message);
		Q_INVOKABLE void ClearNotifications();
		Q_INVOKABLE void SetLoginData(const QVariant &data = QVariant());
		Q_INVOKABLE QVariant GetLoginData() const;
		Q_INVOKABLE void SetSyncKey(const QVariant &v);

		public Q_SLOTS:
		void ActivateWindow();
		void DeactivateWindow();
		void CreateWindow();
		void DestoryWindow();
		void ShowGUI();
		void QmlViewerDestroyed();
		void Quit();
		int RunMode() const;

	private:
		QNetworkAccessManager *oManager;
		QVariantMap tLoginInfo;
		QVariantMap tUserInfo;
		QString sSyncKey;

	private:
		idPipeline(QObject *parent = 0);
		QNetworkAccessManager * NetworkManager();
		bool IsValid() const;

		private Q_SLOTS:
			void finishedSLOT(QNetworkReply *reply);
		void SyncCheck();
};

namespace id
{
	bool register_to_qt_dbus(const QString &service, const QString &path, QObject *obj);
}

#endif
