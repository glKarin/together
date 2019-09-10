#ifndef _KARIN_PIPELINE_H
#define _KARIN_PIPELINE_H

#ifndef _SIMULATOR
#include <QtDBus>
#else
#include <QObject>
#endif
#include <QVariant>

class QNetworkAccessManager;
class QNetworkReply;

class idSyncCheckThread;

class idPipeline : public 
#ifndef _SIMULATOR
									 QDBusAbstractAdaptor
#else
									 QObject
#endif
{
	Q_OBJECT
#ifndef _SIMULATOR
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
				"    <method name=\"DestroyWindow\">\n"  
				"    </method>\n" 
				"    <method name=\"Quit\">\n"  
				"    </method>\n" 
				"    <method name=\"RunMode\">\n"  
				"      <arg name=\"run_mode\" type=\"i\" direction=\"out\"/>\n" 
				"    </method>\n" 
				"  </interface>\n"  
				"")
#endif

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
		void DestroyWindow();
		void ShowGUI();
		void QmlViewerDestroyed();
		void Quit();
		void Boot();
		int RunMode() const;

	private:
		QNetworkAccessManager *oManager;
		QVariantMap tLoginInfo;
		QVariantMap tUserInfo;
		QString sSyncKey;
		idSyncCheckThread *m_thread;

	private:
		idPipeline(QObject *parent = 0);
		bool IsValid() const;
		Q_DISABLE_COPY(idPipeline)

		private Q_SLOTS:
		void SyncCheck();
		void StopCheck();

		friend class idSyncCheckThread;
};

namespace id
{
	bool register_to_qt_dbus(const QString &service, const QString &path, QObject *obj);
}

#endif
