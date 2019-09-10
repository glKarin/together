#include "filemodel.h"

#include <QDir>
#include <QDebug>

#include "id_std.h"

	idFileModel::idFileModel(QObject *parent)
	: idQmlModel_base(parent),
	m_dir(new QDir),
	m_path(QDir::homePath()),
	m_filter(QDir::NoDot | QDir::AllEntries | QDir::Hidden),
	m_sort(QDir::DirsFirst | QDir::Name | QDir::Type | QDir::IgnoreCase)
{
	setObjectName("idFileModel");
	InitRoleMap();
	Restore();
}

idFileModel::~idFileModel()
{
	ID_QOBJECT_DESTROY_DBG
}

int idFileModel::Filter() const
{
	return m_filter;
}

int idFileModel::Sort() const
{
	return m_sort;
}

QString idFileModel::Path() const
{
	return m_path;
}

void idFileModel::SetFilter(int value)
{
	int v;

	v = value;
	v |= QDir::NoDot;
	v &= (~(QDir::NoDotAndDotDot | QDir::NoDotDot));
	if(m_filter != v)
	{
		m_filter = v;
		Restore();
		emit filterChanged(m_filter);
	}
}

void idFileModel::SetSort(int value)
{
	if(m_sort != value)
	{
		m_sort = value;
		Restore();
		emit sortChanged(m_sort);
	}
}

void idFileModel::SetPath(const QString &value)
{
	QFileInfo info(value);
	if(!info.isDir())
		return;

	QString p = info.absoluteFilePath();
	if(m_path != p)
	{
		m_path = p;
		Restore();
		emit pathChanged(m_path);
	}
}

void idFileModel::Restore()
{
	bool isDir;

	//qDebug()<<m_path;
	Clear();

	m_dir->setPath(m_path);
	QFileInfoList list = m_dir->entryInfoList(static_cast<QDir::Filter>(m_filter | (m_path == "/" ? QDir::NoDotDot : 0)), static_cast<QDir::SortFlag>(m_sort));
	ID_CONST_FOREACH(QFileInfoList, list)
	{
		isDir = itor->isDir();
		QVariantMap map;
		map.insert("name", isDir ? itor->fileName() + "/" : itor->fileName());
		map.insert("path", itor->absoluteFilePath());
		map.insert("size", itor->size());
		map.insert("suffix", isDir ? "/" : itor->completeSuffix());
		map.insert("mode", static_cast<int>(itor->permissions()));
		map.insert("owner", itor->owner());
		map.insert("group", itor->group());

		map.insert("alphabet", QString(itor->fileName().at(0).toUpper()));
		Push_back(map);
	}
}

void idFileModel::Back()
{
	SetPath(m_path + "/../");
}

void idFileModel::InitRoleMap()
{
	m_roles.clear();

	ID_QMLMODEL_INSERT_ROLE(idFileModel, name);
	ID_QMLMODEL_INSERT_ROLE(idFileModel, path);
	ID_QMLMODEL_INSERT_ROLE(idFileModel, size);
	ID_QMLMODEL_INSERT_ROLE(idFileModel, mode);
	ID_QMLMODEL_INSERT_ROLE(idFileModel, suffix);
	ID_QMLMODEL_INSERT_ROLE(idFileModel, owner);
	ID_QMLMODEL_INSERT_ROLE(idFileModel, group);

	ID_QMLMODEL_INSERT_ROLE(idFileModel, alphabet);

	setRoleNames(m_roles);
}
