#ifndef NETWORKCONNECTOR_H
#define NETWORKCONNECTOR_H

#include <QObject>
#include <QVariant>

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
    explicit idNetworkConnector(QObject *parent = 0);
    virtual ~idNetworkConnector();
    Q_INVOKABLE QString Request(const QString &url, const QString &field, const QByteArray &data = QByteArray(), int type = 0, const QVariant &headers = QVariant());
		Q_INVOKABLE QString Request_sync(const QString &url, const QByteArray &data = QByteArray(), int type = 0, const QVariant &headers = QVariant());
		int SyncRequest(const QString &url, const QList<QPair<QByteArray, QByteArray> > &querys = QList<QPair<QByteArray, QByteArray> >(), const QByteArray &data = QByteArray(), int type = 0, const QVariant &headers = QVariant(), QByteArray *r = 0, bool redirect = true);
		static idNetworkConnector * Instance();
		Q_INVOKABLE QString ErrorString(int err) const;
		id::idReplyHash_t Replys() const;
		static QByteArray MakePostData(const QVariantMap &map);
		static int SyncRequest_thread(const QString &url, const QList<QPair<QByteArray, QByteArray> > &querys = QList<QPair<QByteArray, QByteArray> >(), const QByteArray &data = QByteArray(), int type = 0, const QVariant &headers = QVariant(), QByteArray *r = 0, bool redirect = true);

Q_SIGNALS:
		void finished(const QString &name, int error, const QString &value);

private Q_SLOTS:
	void finishedSLOT();
    
private:
		QNetworkAccessManager * NetworkManager();
    static void SetRequestHeaders(QNetworkRequest *req, const QVariantMap &headers);
    static void SetRequestHeaders(QNetworkRequest *req, const QVariantList &headers);

private:
		id::idReplyHash_t tReplys;
    
};

#endif // NETWORKMANAGER_H
