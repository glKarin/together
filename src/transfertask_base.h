#ifndef _KARIN_TRANSFERTASK_BASE_H
#define _KARIN_TRANSFERTASK_BASE_H

#include <QObject>
#include <QMap>
#include <QVariant>

class QNetworkAccessManager;
class QNetworkReply;
class QFile;

class idTransferManager;

class idTransferTask_base : public QObject
{
	Q_OBJECT
		Q_PROPERTY(qreal progress READ Progress NOTIFY progressChanged)
		Q_PROPERTY(idType_e type READ Type NOTIFY typeChanged)
		Q_PROPERTY(idStatus_e status READ Status NOTIFY statusChanged)
		Q_PROPERTY(QString filePath READ FilePath WRITE SetFilePath NOTIFY filePathChanged)
		Q_PROPERTY(QString remoteUrl READ RemoteUrl WRITE SetRemoteUrl NOTIFY remoteUrlChanged)
		Q_PROPERTY(int error READ Error NOTIFY errorChanged)
		Q_PROPERTY(QString mediaId READ MediaId WRITE SetMediaId NOTIFY mediaIdChanged)
		Q_PROPERTY(QString msgId READ MsgId WRITE SetMsgId NOTIFY msgIdChanged)
		Q_PROPERTY(qint64 readBytes READ ReadBytes NOTIFY readBytesChanged)
		Q_PROPERTY(qint64 totalBytes READ TotalBytes NOTIFY totalBytesChanged)
		Q_PROPERTY(QString sessionId READ SessionId WRITE SetSessionId NOTIFY sessionIdChanged)
		Q_PROPERTY(int msgType READ MsgType WRITE SetMsgType NOTIFY msgTypeChanged)

		Q_ENUMS(idType_e)
		Q_ENUMS(idStatus_e)

	public:
		enum idType_e
		{
			Type_Download = 0,
			Type_Upload
		};
		enum idStatus_e
		{
			Status_Ready = 0,
			Status_Doing,
			Status_Done,
			Status_Error,
		};

	public:
		virtual ~idTransferTask_base();
		virtual QVariant ToVariant(const QString &name = QString());
		qreal Progress() const;
		idStatus_e Status() const;
		idType_e Type() const;
		int Error() const;
		QString FilePath() const;
		QString RemoteUrl() const;
		QString MediaId() const;
		QString MsgId() const;
		qint64 ReadBytes() const;
		qint64 TotalBytes() const;
		QString SessionId() const;
		int MsgType() const;

		void SetFilePath(const QString &value);
		void SetRemoteUrl(const QString &value);
		void SetMediaId(const QString &value);
		void SetMsgId(const QString &value);
		void SetSessionId(const QString &value);
		void SetMsgType(int value);

		public Q_SLOTS:
			virtual void Transfer() = 0;
			virtual void Retransfer() = 0;
		virtual void Abort();

Q_SIGNALS:
		void progress(qreal progress);
		void started();
		void finished(int error = 0);

		void progressChanged(qreal progress);
		void filePathChanged(const QString &filePath);
		void remoteUrlChanged(const QString &remoteUrl);
		void typeChanged(idType_e type);
		void statusChanged(idStatus_e status);
		void errorChanged(int err);
		void mediaIdChanged(const QString &mediaId);
		void msgIdChanged(const QString &msgId);
		void readBytesChanged(qint64 readBytes);
		void totalBytesChanged(qint64 readBytes);
		void sessionIdChanged(const QString &sessionId);
		void msgTypeChanged(int msgType);

	protected:
		enum idRequestType_e
		{
			RequestType_Get = 0,
			RequestType_Post
		};

	protected Q_SLOTS:
		virtual void finished_slot() = 0;
		virtual void updateProgress_slot(qint64 bytes, qint64 total) = 0;

	protected:
		explicit idTransferTask_base(QObject *parent = 0);
		QNetworkAccessManager * NetworkManager();
		virtual QNetworkReply * Request(const QString &url, const QByteArray &data = QByteArray(), idRequestType_e type = RequestType_Get, const QMap<QByteArray, QByteArray> &headers = QMap<QByteArray, QByteArray>());
		virtual bool Begin() = 0;
		virtual void End() = 0;
		void SetProgress(qreal value);
		void SetError(int value);
		void SetStatus(idStatus_e value);
		void SetReadBytes(qint64 value);
		void SetTotalBytes(qint64 value);
		void SetType(idType_e value);

	protected:
		QFile *m_file;
		qreal m_progress;
		QString m_filePath;
		QString m_remoteUrl;
		idStatus_e m_status;
		idType_e m_type;
		int m_error;
		QString m_mediaId;
		QString m_msgId;
		QString m_sessionId;
		int m_msgType;
		qint64 m_readBytes;
		qint64 m_totalBytes;

		QNetworkReply *m_reply;

		friend class idTransferManager;
		Q_DISABLE_COPY(idTransferTask_base)
};

#endif
