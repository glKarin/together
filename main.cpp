#include <QtGui/QApplication>
#include <QtDeclarative>
#include <QLocale>
#include <QTranslator>
#include <QTextCodec>
#include <QDebug>
#include "qmlapplicationviewer.h"

#include "id_std.h"
#include "utility.h"
#include "pipeline.h"
#include "networkconnector.h"
#include "networkmanager.h"
#include "qtm/qdeclarativewebview.h"
#ifdef _KARIN_MM_EXTENSIONS
#include "qtm/qdeclarativevideo_p.h"
#endif

static idUtility *ut = 0;
static idPipeline *pipeline = 0;
static idNetworkConnector *connector = 0;
idDeclarativeNetworkAccessManagerFactory factory;

namespace id
{
	class QmlApplicationViewer;
}

id::QmlApplicationViewer *qml_viewer;
bool lock = false;
bool inited = false;

namespace id
{
	class QmlApplicationViewer : public ::QmlApplicationViewer
	{
		virtual void closeEvent(QCloseEvent *event)
		{
			if(idUtility::Instance()->RunMode() == idUtility::RunMode_Only_Hide_Window)
			{
				hide();
				event->ignore();
			}
			else
				::QmlApplicationViewer::closeEvent(event);
		}
	};

	bool try_to_run_app_instance()
	{
		QDBusInterface interface("com." ID_DEV "." ID_PKG, "/com/" ID_DEV "/" ID_PKG, "com." ID_DEV "." ID_PKG);
		if(!interface.isValid())
		{
			qDebug() << "Run new singleton instance";
			return false;
		}
		qDebug() << "Try to call singleton instance";
		QDBusMessage msg = interface.call("ShowGUI");
		return true;
	}

	void create_qml_viewer()
	{
		QDeclarativeEngine *engine;
		QDeclarativeContext *context;

		if(!inited)
			return;
		if(lock)
			return;
		if(qml_viewer)
			return;

		lock = true;
		qml_viewer = new id::QmlApplicationViewer;
		qml_viewer->setAttribute(Qt::WA_DeleteOnClose, true);
		engine = qml_viewer->engine();
		context = engine->rootContext();
		engine->setNetworkAccessManagerFactory(&factory);
		connector->SetEngine(engine);
		ut->SetEngine(engine);

		context->setContextProperty("_UT", ut);
		context->setContextProperty("_CONNECTOR", connector);
		context->setContextProperty("_PIPELINE", pipeline);

		QObject::connect(qml_viewer, SIGNAL(destroyed()), pipeline, SLOT(QmlViewerDestroyed()));
		QObject::connect(engine, SIGNAL(quit()), pipeline, SLOT(Quit()));
		qml_viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
		qml_viewer->setMainQmlFile(QLatin1String("qml/" ID_PKG "/main.qml"));
		qml_viewer->showExpanded();
		lock = false;
	}
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
	QApplication *a;
	QTranslator translator;
	QString qm, qmdir;
	const QString RegisterUncreatableTypeMsg(QString("[ERROR]: %1 -> %2").arg("Can not create a single-instance object"));

	a = createApplication(argc, argv);

	if(id::try_to_run_app_instance())
	{
		a->quit();
		return 0;
	}

	switch(idUtility::Instance()->RunMode())
	{
		case idUtility::RunMode_Close_Window:
			qDebug() << "Application window will close when running on background";
			break;
		case idUtility::RunMode_Only_Hide_Window:
			qDebug() << "Application window will hide when running on background";
			break;
		case idUtility::RunMode_Not_Run_On_Background:
		default:
			qDebug() << "Application do not run on background";
			break;
	}
	if(idUtility::Instance()->RunMode() == idUtility::RunMode_Close_Window)
		QApplication::setQuitOnLastWindowClosed(false);

	QScopedPointer<QApplication> app(a);
	a->setApplicationName(ID_PKG);
	a->setApplicationVersion(ID_VER);
	a->setOrganizationName(ID_DEV);
	QTextCodec::setCodecForCStrings(QTextCodec::codecForName("UTF-8"));

	QString locale = QLocale::system().name();
#ifdef _HARMATTAN
#ifdef _DBG
	qm = ID_PKG ".zh_CN.qm";
	qmdir = "i18n/";
#else
	qm = QString(ID_PKG ".") + locale;
	qmdir = "/opt/" ID_PKG "/i18n/";
#endif
#else
#ifdef _DBG
	Q_INIT_RESOURCE(ID_PKG);
	qm = QString(":/i18n/" ID_PKG ".") + locale;
#else
	qm = QString("qt_") + locale;
	qmdir = QLibraryInfo::location(QLibraryInfo::TranslationsPath);
#endif
#endif
	if(translator.load(qm, qmdir))
	{
		qDebug() << QString("[INFO]: Load i18n -> %1: %2 [%3]").arg(locale).arg(qm).arg(qmdir);
		a->installTranslator(&translator);
	}
	else
		qWarning() << QString("[DEBUG]: Not found i18n -> %1: %2 [%3]").arg(locale).arg(qm).arg(qmdir);

	qmlRegisterType<QDeclarativeWebView>(ID_QML_URI, ID_QML_MAJOR_VER, ID_QML_MINOR_VER, ID_APP "WebView");
	qmlRegisterType<QDeclarativeWebSettings>();
#ifdef _KARIN_MM_EXTENSIONS
	qmlRegisterType<QDeclarativeVideo>(ID_QML_URI, ID_QML_MAJOR_VER, ID_QML_MINOR_VER, ID_APP "Video");
#endif
	qmlRegisterUncreatableType<idNetworkConnector>(ID_QML_URI, ID_QML_MAJOR_VER, ID_QML_MINOR_VER, ID_APP "NetworkConnector", RegisterUncreatableTypeMsg.arg("idNetworkConnector"));

	ut = idUtility::Instance();
	connector = idNetworkConnector::Instance();
	pipeline = idPipeline::Create(qApp);

	inited = true;

	id::create_qml_viewer();

	return app->exec();
}
