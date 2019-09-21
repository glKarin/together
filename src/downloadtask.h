#ifndef _KARIN_DOWNLOADTASK_H
#define _KARIN_DOWNLOADTASK_H

#include "transfertask_base.h"

class idTransferManager;

class idDownloadTask : public idTransferTask_base
{
	Q_OBJECT

	public:
		explicit idDownloadTask(QObject *parent = 0);
		virtual ~idDownloadTask();

		public Q_SLOTS:
			virtual void Transfer();
			virtual void Retransfer();

	private Q_SLOTS:
		virtual void finished_slot();
		virtual void updateProgress_slot(qint64 bytes, qint64 total);
		virtual void readyRead_slot();

	protected:
		virtual bool Begin();
		virtual void End();

	private:
		void GuessFileSuffix();

		friend class idTransferManager;
		Q_DISABLE_COPY(idDownloadTask)
};

#endif

