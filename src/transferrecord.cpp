#include "transferrecord.h"

#include <QDateTime>
#include <QFileInfo>
#include <QFile>
#include <QDir>
#include <QDebug>

#include "database.h"
#include "transfertask_base.h"

#define ID_TABLE_PREFIX "id"

extern idDatabase *globalDb;

	idTransferRecord::idTransferRecord(QObject *parent)
: idQmlModel_base(parent),
	m_db(globalDb),
	m_mode(idTransferRecord::Mode_All),
	m_tableName(ID_TABLE_PREFIX "_transfer_record")
{
	setObjectName("idTransferRecord");
	InitRoleMap();
	InitDBTable();
	Restore();
}

idTransferRecord::~idTransferRecord()
{
	ID_QOBJECT_DESTROY_DBG
}

idTransferRecord::idMode_e idTransferRecord::Mode() const
{
	return m_mode;
}

void idTransferRecord::SetMode(idTransferRecord::idMode_e mode)
{
	if(m_mode != mode)
	{
		m_mode = mode;
		Restore();
		emit modeChanged(m_mode);
	}
}

void idTransferRecord::Clean(int mode)
{
	bool ok;

	if(mode & 4)
	{
		m_db->Table(m_tableName).AddField("path");
		if(m_mode != idTransferRecord::Mode_All)
		{
			m_db->And("mode", m_mode == idTransferRecord::Mode_Upload ? 1 : 0);
		}
		idSqlResultCol_t cols = m_db->Col();
		ID_CONST_FOREACH(idSqlResultCol_t, cols)
		{
			ok = QFile::remove(itor->toString());
			if(!ok)
				qDebug() << "[Debug]: remove transfer file error -> " << itor->toString();
		}
	}
	if(mode & 2)
	{
		m_db->Table(m_tableName);
		if(m_mode != idTransferRecord::Mode_All)
		{
			m_db->And("mode", m_mode == idTransferRecord::Mode_Upload ? 1 : 0);
		}
		m_db->Delete();
	}

	if((mode & 1) || 1)
	{
		Clear();
	}
}

void idTransferRecord::Dump(idTransferTask_base *task)
{
	int ret;
	int mode;
	idDatabase *db;

	if(task->Status() != idTransferTask_base::Status_Done)
		return;

	db = globalDb;
	QString tableName(ID_TABLE_PREFIX "_transfer_record");
	QVariantMap map;
	QFileInfo info(task->FilePath());
	QString path = info.absoluteFilePath();
	mode = task->Type() == idTransferTask_base::Type_Upload ? 1 : 0;
	ret = db->Table(tableName).And("path", path, "=", 1).And("mode", mode).AddField("id").One().toInt();
	if(ret)
	{
		map.insert("updated_time", QDateTime::currentMSecsSinceEpoch());
		ret = db->Table(tableName).And("id", ret).Update(map);
		if(!ret)
			qWarning() << "[Warning]: Update transfer data error.";
	}
	else
	{
		map.insert("path", ID_SQL_QUOTE_VALUE(path));
		map.insert("mode", mode);
		map.insert("updated_time", QDateTime::currentMSecsSinceEpoch());
		ret = db->Table(tableName).Insert(map).toInt();
		if(!ret)
			qWarning() << "[Warning]: Insert transfer data error.";
	}
}

void idTransferRecord::Restore()
{
	Clear();
	m_db->Table(m_tableName).AddOrder("updated_time", "DESC");
	if(m_mode != idTransferRecord::Mode_All)
	{
		m_db->And("mode", m_mode == idTransferRecord::Mode_Upload ? 1 : 0);
	}
	idSqlResultList_t res = m_db->Select();
	ID_FOREACH(idSqlResultList_t, res)
	{
		QFileInfo info(itor->value("path").toString());
		if(!info.exists())
			itor->operator[]("path").clear();
		itor->operator[]("type") = info.completeSuffix().toLower();
		itor->operator[]("name") = info.fileName();
		itor->operator[]("size") = info.size();

		itor->operator[]("date") = QDateTime::fromMSecsSinceEpoch(itor->value("updated_time").value<qint64>()).toString("yyyy-MM-dd");
		Push_back(*itor);
	}
}

void idTransferRecord::Delete(int id, bool file)
{
	int ret;
	int size;

	size = rowCount();
	for(int i = 0; i < size; i++)
	{
		if(GetValuev<int>(i, "id") == id)
		{
			if(file)
			{
				QString path = GetValuev<QString>(i, "path");
				if(!path.isEmpty())
					QFile::remove(path);
			}
			Remove(i);
			break;
		}
	}

	ret = m_db->Table(m_tableName).And("id", id).Delete();
	if(!ret)
		qWarning() << "[Warning]: Delete transfer data error.";
}

void idTransferRecord::InitRoleMap()
{
	m_roles.clear();

	ID_QMLMODEL_INSERT_ROLE(idTransferRecord, id);
	ID_QMLMODEL_INSERT_ROLE(idTransferRecord, name);
	ID_QMLMODEL_INSERT_ROLE(idTransferRecord, size);
	ID_QMLMODEL_INSERT_ROLE(idTransferRecord, path);
	ID_QMLMODEL_INSERT_ROLE(idTransferRecord, updated_time);
	ID_QMLMODEL_INSERT_ROLE(idTransferRecord, type);
	ID_QMLMODEL_INSERT_ROLE(idTransferRecord, mode);

	ID_QMLMODEL_INSERT_ROLE(idTransferRecord, date);

	setRoleNames(m_roles);
}

void idTransferRecord::InitDBTable()
{
	if(m_tableName.isEmpty())
		return;

	QVariantMap map;
	map.insert("id", "INTEGER PRIMARY KEY AUTOINCREMENT");
	map.insert("path", "TEXT NOT NULL");
	map.insert("mode", "INTEGER DEFAULT 0");
	map.insert("updated_time", "INTEGER DEFAULT 0");

	m_db->Create(m_tableName, map);
}
