#ifndef NETWORKCONNECTOR_H
#define NETWORKCONNECTOR_H

#include <QObject>
#include <QVariant>

class QDeclarativeEngine;
class QNetworkReply;
class QNetworkRequest;
class QNetworkAccessManager;

namespace id
{
	typedef QHash<QNetworkReply *, QString> idReplyHash_t;
}

class idNetworkConnector : public QObject
{
    Q_OBJECT

			Q_ENUMS(idConnectType_e)
			Q_ENUMS(idErrorType_e)
public:
enum idConnectType_e
{
	Connect_Get = 0,
	Connect_Post,
	Connect_Put,
	Connect_Delete,
};

enum idErrorType_e
{
	Error_Connector_Not_Inititalized = -1,
	Error_Reply_Data_Uncompress_Fail = -2,
	Error_Reply_Not_Found = -3,
	Error_Request_Field_Not_Found = -4,
	Error_Data_Write_Fail = -5,
};

public:
    virtual ~idNetworkConnector();
    Q_INVOKABLE QString Request(const QString &url, const QString &field, const QByteArray &data = QByteArray(), int type = 0, const QVariant &headers = QVariant());
    void SetRequestHeaders(QNetworkRequest *req, const QVariantMap &headers);
    void SetRequestHeaders(QNetworkRequest *req, const QVariantList &headers);
		void SetEngine(QDeclarativeEngine *engine);
		QDeclarativeEngine * Engine();
		static idNetworkConnector * Instance();
		Q_INVOKABLE QString ErrorString(int err) const;
		id::idReplyHash_t Replys() const;

Q_SIGNALS:
		void finished(const QString &name, int error, const QString &value);

private Q_SLOTS:
	void finishedSLOT();
    
private:
    explicit idNetworkConnector(QObject *parent = 0);
		QNetworkAccessManager * Manager();

private:
		QDeclarativeEngine *oEngine;
		id::idReplyHash_t tReplys;
    
};

#endif // NETWORKMANAGER_H
