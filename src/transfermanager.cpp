#include "transfermanager.h"

#include <QFileInfo>
#include <QDebug>

#include "downloadtask.h"
#include "uploadtask.h"
#include "transferrecord.h"

	idTransferManager::idTransferManager(QObject *parent)
	: QObject(parent),
	m_path(ID_DATA_DOWNLOAD_PATH)
{
	setObjectName("idTransferManager");
}

idTransferManager::~idTransferManager()
{
	ID_QOBJECT_DESTROY_DBG
}

QList<QObject *> idTransferManager::List() const
{
	return m_list;
}

QString idTransferManager::Path() const
{
	return m_path;
}

idTransferTask_base * idTransferManager::GetTask(const QString &mid)
{
	idTransferTask_base *task;

	ID_CONST_FOREACH(QList<QObject *>, m_list)
	{
		task = static_cast<const idTransferTask_base *>(*itor);
		if(task->MsgId() == mid)
		{
			return task;
		}
	}
	return 0;
}

int idTransferManager::GetTaskIndex(const QString &mid)
{
	const idTransferTask_base *task;

	for(int i = 0; i < m_list.size(); i++)
	{
		task = static_cast<const idTransferTask_base *>(m_list[i]);
		if(task->MsgId() == mid)
		{
			return i;
		}
	}
	return -1;
}

int idTransferManager::Upload(const QString &to, const QString &from, const QString &localId, int type, const QString &sessionId, const QVariant &params)
{
	idTransferTask_base *task;
	idUploadTask *upload_task;
	int r;

	r = 0;
	task = GetTask(localId);
	if(task)
	{
		switch(task->Status())
		{
			case idTransferTask_base::Status_Error:
				qDebug() << "[Debug]: File upload error.";
				//task->Retransfer();
				r = idTransferTask_base::Status_Error;
				break;
			case idTransferTask_base::Status_Doing:
				qDebug() << "[Debug]: File is uploading.";
				r = idTransferTask_base::Status_Doing;
				break;
			case idTransferTask_base::Status_Done:
				qDebug() << "[Debug]: File is upload successful.";
				r = idTransferTask_base::Status_Done;
				break;
			case idTransferTask_base::Status_Ready:
			default:
				r = idTransferTask_base::Status_Ready;
				break;
		}
		return r;
	}

	QVariantMap map = params.toMap();
	task = new idUploadTask;
	task->SetRemoteUrl(to);
	task->SetFilePath(from);
	task->SetMsgId(localId); // local_id
	task->SetSessionId(sessionId);
	task->SetMsgType(type);
	upload_task = static_cast<idUploadTask *>(task);
	upload_task->SetUname(map.value("ToUserName").toString());
	upload_task->SetPostParams(map);
	connect(task, SIGNAL(progressChanged(qreal)), this, SLOT(progress_slot(qreal)));
	connect(task, SIGNAL(started()), this, SLOT(started_slot()));
	connect(task, SIGNAL(finished(int)), this, SLOT(finished_slot(int)));
	task->Transfer();
	m_list.push_back(task);
	emit listChanged(m_list);
	r = idTransferTask_base::Status_Doing;

	return r;
}

int idTransferManager::Download(const QString &from, const QString &mid, const QString &mediaId, int type, const QString &sessionId, const QString &fileName)
{
	idTransferTask_base *task;
	int r;

	r = 0;
	task = GetTask(mid);
	if(task)
	{
		switch(task->Status())
		{
			case idTransferTask_base::Status_Error:
				qDebug() << "[Debug]: File transfer error.";
				//task->Retransfer();
				r = idTransferTask_base::Status_Error;
				break;
			case idTransferTask_base::Status_Doing:
				qDebug() << "[Debug]: File is transfering.";
				r = idTransferTask_base::Status_Doing;
				break;
			case idTransferTask_base::Status_Done:
				qDebug() << "[Debug]: File is transfer successful.";
				r = idTransferTask_base::Status_Done;
				break;
			case idTransferTask_base::Status_Ready:
			default:
				r = idTransferTask_base::Status_Ready;
				break;
		}
		return r;
	}

	task = new idDownloadTask;
	task->SetRemoteUrl(from);
	task->SetFilePath(GenerateDownloadFileName(mid, type, fileName));
	task->SetMediaId(mediaId);
	task->SetMsgId(mid);
	task->SetSessionId(sessionId);
	task->SetMsgType(type);
	connect(task, SIGNAL(progressChanged(qreal)), this, SLOT(progress_slot(qreal)));
	connect(task, SIGNAL(started()), this, SLOT(started_slot()));
	connect(task, SIGNAL(finished(int)), this, SLOT(finished_slot(int)));
	task->Transfer();
	m_list.push_back(task);
	emit listChanged(m_list);
	r = idTransferTask_base::Status_Doing;

	return r;
}

QVariant idTransferManager::GetTaskValue(const QString &mid, const QString &name) const
{
	idTransferTask_base *task;

	ID_CONST_FOREACH(QList<QObject *>, m_list)
	{
		task = static_cast<idTransferTask_base *>(*itor);
		if(task->MsgId() == mid)
		{
			return task->ToVariant(name);
		}
	}
	return QVariant();
}

QString idTransferManager::GenerateDownloadFileName(const QString &msgId, int type, const QString &fileName) const
{
	int index;
	QString baseName;
	QString extName;
	QString dir;

	index = 0;
	if(!fileName.isEmpty())
	{
		QFileInfo info(fileName);
		baseName = info.baseName();
		extName = "." + info.completeSuffix();
	}
	else
	{
		switch(type)
		{
			case idTransferManager::FileType_Voice:
				extName = ".mp3";
				dir = "/voice";
				break;
			case idTransferManager::FileType_Video:
			case idTransferManager::FileType_MicroVideo:
				extName = ".mp4";
				dir = "/video";
				break;
			case idTransferManager::FileType_Image:
				extName = ".jpg";
				dir = "/image";
				break;
			case idTransferManager::FileType_Emoji:
				extName = ".gif";
				dir = "/emoji";
				break;
			default:
				extName = "";
				break;
		}
		baseName = msgId;
	}
	id::mkdirs(m_path + dir);
	return id::generate_file_name(baseName + extName, m_path + dir);
}

void idTransferManager::finished_slot(int error)
{
	idTransferTask_base *task;

	task = static_cast<idTransferTask_base *>(sender());
	if(!task)
		return;
	idTransferRecord::Dump(task);
	if(task->m_type == idTransferTask_base::Type_Upload)
		emit uploadFinished(task->m_sessionId, task->m_msgId, error);
	else
		emit downloadFinished(task->m_sessionId, task->m_msgId, error);
	emit transferFinished(task->m_type, task->m_sessionId, task->m_msgId, error);
}

void idTransferManager::started_slot()
{
	idTransferTask_base *task;

	task = static_cast<idTransferTask_base *>(sender());
	if(!task)
		return;
	if(task->m_type == idTransferTask_base::Type_Upload)
		emit uploadStarted(task->m_sessionId, task->m_msgId);
	else
		emit downloadStarted(task->m_sessionId, task->m_msgId);
	emit transferStarted(task->m_type, task->m_sessionId, task->m_msgId);
}

void idTransferManager::progress_slot(qreal progress)
{
	idTransferTask_base *task;

	task = static_cast<idTransferTask_base *>(sender());
	if(!task)
		return;
	if(task->m_type == idTransferTask_base::Type_Upload)
		emit uploadProgress(task->m_sessionId, task->m_msgId, progress);
	else
		emit downloadProgress(task->m_sessionId, task->m_msgId, progress);
	emit transferProgress(task->m_type, task->m_sessionId, task->m_msgId, progress);
}

int idTransferManager::Retransfer(const QString &mid)
{
	idTransferTask_base *task;

	task = GetTask(mid);
	if(task && task->Status() == idTransferTask_base::Status_Error)
	{
		qDebug() << "[Debug]: File will retransfer.";
		task->Retransfer();
		return 0;
	}

	return 1;
}

ID_SINGLE_INSTANCE_DECL(idTransferManager)
