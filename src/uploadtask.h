#ifndef _KARIN_UPLOADTASK_H
#define _KARIN_UPLOADTASK_H

#include "transfertask_base.h"

#include <QVariant>

class idTransferManager;

class idUploadTask : public idTransferTask_base
{
	Q_OBJECT
		Q_PROPERTY(QString uname READ Uname WRITE SetUname NOTIFY unameChanged)

	public:
		explicit idUploadTask(QObject *parent = 0);
		virtual ~idUploadTask();
		virtual QVariant ToVariant(const QString &name = QString());
		void SetPostParams(const QVariantMap &params);
		QMap<QByteArray, QByteArray> PostParams() const;
		QByteArray ResponseData() const;
		QString Uname() const;
		void SetUname(const QString &value);

		public Q_SLOTS:
			virtual void Transfer();
			virtual void Retransfer();

Q_SIGNALS:
			void unameChanged(const QString &uname);

	private Q_SLOTS:
		virtual void finished_slot();
		virtual void updateProgress_slot(qint64 bytes, qint64 total);

	protected:
		virtual bool Begin();
		virtual void End();

	private:
		void MakePostData(QByteArray &r, QMap<QByteArray, QByteArray> &h);
		void SetResponseData(const QByteArray &data = QByteArray());
		bool NextParkChunk();
		void Send(int p = 0);

	private:
		QMap<QByteArray, QByteArray> m_postParams;
		QByteArray m_responseData;
		qint64 m_pos; // last send position
		int m_size; // last send size
		int m_part; // send part
		int m_total; // total chunks
		qint64 m_fileSize;
		QString m_uname;
		unsigned int m_id;

		static unsigned int _id;
		friend class idTransferManager;
		Q_DISABLE_COPY(idUploadTask)
};

#endif
