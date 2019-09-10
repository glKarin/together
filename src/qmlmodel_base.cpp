#include "qmlmodel_base.h"

#include <QDebug>

#define ID_TABLE_PREFIX "id"

	idQmlModel_base::idQmlModel_base(QObject *parent)
: QAbstractListModel(parent)
{
	setObjectName("idQmlModel_base");
}

idQmlModel_base::~idQmlModel_base()
{
	//ID_QOBJECT_DESTROY_DBG
}

int idQmlModel_base::rowCount(const QModelIndex &index) const
{
	Q_UNUSED(index)
		return m_list.size();
}

QVariant idQmlModel_base::data(const QModelIndex &index, int role) const
{
	//qDebug()<<role<<m_list[index.row()][m_roles[role]];
	if(m_roles.contains(role))
		return m_list[index.row()][m_roles[role]];
	return QVariant();
}

QVariant idQmlModel_base::GetValue(int index, const QString &name) const
{
	if(index < 0 || index >= m_list.size())
	{
		qWarning() << "[Warning]: " << objectName() << "index is over" << "(" << index << " < " << m_list.size() << ")";
		return QVariant();
	}
	const QVariantMap &m = m_list[index];
	if(m.contains(name))
	{
		//qDebug()<<name<<m[name];
		return m[name];
	}
	return QVariant();
}

QVariant idQmlModel_base::SetValue(int index, const QString &name, const QVariant &data)
{
	QVariant old;

	if(index < 0 || index >= m_list.size())
	{
		qWarning() << "[Warning]: " << objectName() << "index is over" << "(" << index << " < " << m_list.size() << ")";
		return QVariant();
	}
	QVariantMap &m = m_list[index];
	if(m.contains(name))
	{
		old = m[name];
		m[name] = data;
		return old;
	}
	return QVariant();
}

void idQmlModel_base::Clear()
{
	beginRemoveRows(QModelIndex(), 0, rowCount());
	m_list.clear();
	endRemoveRows();
	emit countChanged(m_list.size());
}

idQmlModel_base & idQmlModel_base::operator<<(const QVariantMap &data)
{
	m_list.push_back(data);
	return *this;
}

idQmlModel_base & idQmlModel_base::Push_back(const QVariantMap &data)
{
	beginInsertRows(QModelIndex(), rowCount(), rowCount());
	m_list.push_back(data);
	endInsertRows();
	emit countChanged(m_list.size());
	return *this;
}

void idQmlModel_base::operator=(const idQmlModelData_t &data)
{
	m_list = data;
	emit countChanged(m_list.size());
	emit dataChanged(index(0), index(rowCount()));
}

idQmlModel_base::operator idQmlModelData_t &()
{
	return m_list;
}

void idQmlModel_base::Update()
{
	emit countChanged(m_list.size());
	emit dataChanged(index(0), index(rowCount()));
}

QVariantMap idQmlModel_base::Get(int index) const
{
	if(index < 0 || index >= m_list.size())
	{
		qWarning() << "[Warning]: " << objectName() << "index is over" << "(" << index << " < " << m_list.size() << ")";
		return QVariantMap();
	}
	return m_list[index];
}

idQmlModel_base & idQmlModel_base::Remove(int start, int count)
{
	beginRemoveRows(QModelIndex(), start, start + count - 1);
	for(int i = 0; i < count; i++)
	{
		m_list.removeAt(start + i);
	}
	endRemoveRows();
	emit countChanged(m_list.size());
	return *this;
}

QVariant idQmlModel_base::get(int index)
{
	return Get(index);
}

