#ifndef _KARIN_TRANSFERMANAGER_H
#define _KARIN_TRANSFERMANAGER_H

#include <QObject>
#include <QList>

#include "id_std.h"

#define ID_DATA_DOWNLOAD_PATH ID_DATA_PATH "/downloads"

class idTransferTask_base;

class idTransferManager : public QObject
{
	Q_OBJECT
		Q_PROPERTY(QList<QObject *> list READ List NOTIFY listChanged)
		Q_PROPERTY(QString path READ Path FINAL)
		Q_ENUMS(idFileType_e)

	public:
		enum idFileType_e
		{
			FileType_File = 49,
			FileType_Image = 3,
			FileType_Voice = 34,
			FileType_Video = 62,
			FileType_MicroVideo = 43,
			FileType_Emoji = 47,
		};

	public:
		virtual ~idTransferManager();
		ID_SINGLE_INSTANCE_DEF(idTransferManager)
			QList<QObject *> List() const;
		QString Path() const;
		idTransferTask_base * GetTask(const QString &mid);
		Q_INVOKABLE int GetTaskIndex(const QString &mediaId);
		Q_INVOKABLE QVariant GetTaskValue(const QString &mid, const QString &name = QString()) const;

		public Q_SLOTS:
			int Upload(const QString &to, const QString &from, const QString &localId, int type, const QString &sessionId, const QVariant &params);
		int Download(const QString &from, const QString &mid, const QString &mediaId, int type, const QString &sessionId, const QString &fileName = QString());
		int Retransfer(const QString &mid);

Q_SIGNALS:
		void listChanged(const QList<QObject *> &list);
		void transferProgress(int mode, const QString &sessionId, const QString &msgId, qreal progress);
		void transferStarted(int mode, const QString &sessionId, const QString &msgId);
		void transferFinished(int mode, const QString &sessionId, const QString &msgId, int error);
		void downloadProgress(const QString &sessionId, const QString &msgId, qreal progress);
		void downloadStarted(const QString &sessionId, const QString &msgId);
		void downloadFinished(const QString &sessionId, const QString &msgId, int error);
		void uploadProgress(const QString &sessionId, const QString &msgId, qreal progress);
		void uploadStarted(const QString &sessionId, const QString &msgId);
		void uploadFinished(const QString &sessionId, const QString &msgId, int error);

		private Q_SLOTS:
			void finished_slot(int error);
		void started_slot();
		void progress_slot(qreal progress);

	private:
		explicit idTransferManager(QObject *parent = 0);
		QString GenerateDownloadFileName(const QString &msgId, int type, const QString &fileName = QString()) const;

	private:
		QList<QObject *> m_list;
		QString m_path;

		Q_DISABLE_COPY(idTransferManager)
};

#endif
