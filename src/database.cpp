#include "database.h"

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>
#include <QDesktopServices>
#include <QDir>
#include <QDebug>

#include "id_std.h"

#define SQL_DBG
#define CHECK(ret) \
	if(!Check()) { \
		qWarning() << "[Error]: QSQLDatabase is not connect when call " << __func__; \
		return ret; \
	}
#define SQLERR(ret) \
	if(!ok) { \
		QSqlError err = query.lastError(); \
		SetErr(err.type(), err.text()); \
		qWarning() << "[Warning]: SQL Error] ->" << __func__ << ": "<< m_errno << " -> " << m_error; \
		return ret; \
	}
#define DBERR(ret) \
	if(!ok) { \
		QSqlError err = m_db->lastError(); \
		SetErr(err.type(), err.text()); \
		qWarning() << "[Warning]: SQL Error -> " << __func__ << ": "<< m_errno << " -> " << m_error; \
		return ret; \
	}

	idDatabase::idDatabase()
: m_db(0),
	m_start(1),
	m_limit(-1)
{
	// setObjectName("idDatabase");
}

idDatabase::~idDatabase()
{
	ID_DESTROY_DBG("idDatabase")
	//Disconnect();
}

bool idDatabase::Connect(const QString &name, const QString &user, const QString &password)
{
	Disconnect();
	QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", name);

	if(!db.isValid())
		return false;

	m_db = new QSqlDatabase(db);
#ifdef _HARMATTAN
	QString dir(QDesktopServices::storageLocation(QDesktopServices::DataLocation));
	id::mkdirs(dir);
#endif
	m_db->setDatabaseName(
#ifdef _HARMATTAN
			dir + "/" + 
#endif
			name + ".db");

	qDebug()<<m_db->databaseName();
#ifdef _HARMATTAN
	if(!user.isEmpty())
	{
		m_db->setUserName(user);
		if(!password.isEmpty())
			m_db->setPassword(password);
	}
#endif
	m_db->setHostName(ID_DEV);
	m_db->open();

	return m_db->isOpen();
}

void idDatabase::Disconnect()
{
	if(!m_db)
		return;
	if(m_db->isOpen())
	{
		QSqlDatabase::removeDatabase(m_db->connectionName());
		m_db->close();
	}
	delete m_db;
	m_db = 0;
}

bool idDatabase::Check() const
{
	return m_db && m_db->isValid() && m_db->isOpen();
}

void idDatabase::Reset()
{
	m_fields.clear();
	m_conditions.clear();
	m_orders.clear();
	m_sql.clear();
	m_start = 1;
	m_limit = -1;
}

idDatabase & idDatabase::Table(const QString &table)
{
	if(m_table != table)
	{
		m_table = table;
	}
	Reset();
	return *this;
}

idDatabase & idDatabase::And(const QString &name, const QVariant &value, const QString &op, int type)
{
	QString s;

	s += name;
	if(!value.isNull())
	{
		s += " " + op + " ";
		s += (type == 1 ? "'" + value.toString() + "'" : (type == 2 ? "(" + value.toString() + ")" : value.toString()));
	}
	else
	{
		if(type != 0)
		{
			s += " " + op + " ";
			s += type == 1 ? "''" : "()";
		}
	}

	if(m_conditions.isEmpty())
		m_conditions.push_back(s);
	else
		m_conditions.push_back("AND " + s);

	return *this;
}

idDatabase & idDatabase::Or(const QString &name, const QVariant &value, const QString &op, int type)
{
	QString s;

	s += name;
	if(!value.isNull())
	{
		s += " " + op + " ";
		s += (type == 1 ? "'" + value.toString() + "'" : (type == 2 ? "(" + value.toString() + ")" : value.toString()));
	}
	else
	{
		if(type != 0)
		{
			s += " " + op + " ";
			s += type == 1 ? "''" : "()";
		}
	}

	if(m_conditions.isEmpty())
		m_conditions.push_back(s);
	else
		m_conditions.push_back("OR " + s);

	return *this;
}

idDatabase & idDatabase::Limit(int start, int limit)
{
	m_start = start;
	m_limit = limit;
	return *this;
}

idDatabase & idDatabase::Page(int pn, int ps)
{
	m_start = (pn - 1) * ps;
	m_limit = ps;
	return *this;
}

idDatabase & idDatabase::Fields(const QStringList &list)
{

	if(list.isEmpty())
	{
		m_fields.clear();
	}
	else
	{
		ID_CONST_FOREACH(QStringList, list)
		{
			if(m_fields.contains(*itor))
				continue;
			m_fields.push_back(*itor);
		}
	}
	return *this;
}

idDatabase & idDatabase::AddField(const QString &name, const QString &alias)
{
	QString s;

	s += name;
	if(!alias.isEmpty())
		s += " AS " + alias;
	if(!m_fields.contains(s))
		m_fields.push_back(s);

	return *this;
}

idDatabase & idDatabase::Orders(const QStringList &list)
{
	if(list.isEmpty())
	{
		m_orders.clear();
	}
	else
	{
		ID_CONST_FOREACH(QStringList, list)
		{
			if(m_orders.contains(*itor))
				continue;
			m_orders.push_back(*itor);
		}
	}
	return *this;
}

idDatabase & idDatabase::AddOrder(const QString &name, const QString &t)
{
	QString s;

	s += name;
	if(!t.isEmpty())
		s += " " + t;

	if(!m_orders.contains(s))
		m_orders.push_back(s);
	return *this;
}

QString idDatabase::SQL() const
{
	return m_sql;
}

idSqlResultList_t idDatabase::Select()
{
	idSqlResultList_t r;
	bool ok;
	QSqlRecord record;
	int count;
	QStringList cols;

	m_sql.clear();
	m_sql += "SELECT " + (m_fields.isEmpty() ? "*" : m_fields.join(", ")) + " FROM " + m_table;
	if(!m_conditions.isEmpty())
	{
		m_sql += " WHERE " + m_conditions.join(" ");
	}
	if(!m_orders.isEmpty())
	{
		m_sql += " ORDER BY " + m_orders.join(", ");
	}
	if(m_start > 1 || m_limit > 0)
	{
		m_sql += " LIMIT " + QString::number(m_start);
		if(m_limit > 0)
			m_sql += ", " + QString::number(m_limit);
	}

#ifdef SQL_DBG
	qDebug() << m_sql;
#endif
	CHECK(r)

		QSqlQuery query = m_db->exec();
	ok = query.exec(m_sql);
	SQLERR(r)

		record = query.record();
	count = record.count();
	for(int i = 0; i < count; i++)
		cols.push_back(record.fieldName(i));
	while(query.next())
	{
		record = query.record();
		idSqlResultRow_t row;
		ID_CONST_FOREACH(QStringList, cols)
		{
			row.insert(*itor, record.value(*itor));
		}
		r.push_back(row);
	}
	return r;
}

int idDatabase::Count()
{
	bool ok;

	m_sql.clear();
	m_sql += "SELECT COUNT(1) FROM " + m_table;
	if(!m_conditions.isEmpty())
	{
		m_sql += " WHERE " + m_conditions.join(" ");
	}
	if(m_start > 1 || m_limit > 0)
	{
		m_sql += " LIMIT " + QString::number(m_start);
		if(m_limit > 0)
			m_sql += ", " + QString::number(m_limit);
	}
#ifdef SQL_DBG
	qDebug() << m_sql;
#endif
	CHECK(-1)

		QSqlQuery query = m_db->exec();
	ok = query.exec(m_sql);
	SQLERR(-1)

		if(!query.next())
			return -1;
	QSqlRecord record = query.record();
	return record.value(0).toInt();
}

idSqlResultRow_t idDatabase::Row()
{
	idSqlResultRow_t r;
	bool ok;
	QSqlRecord record;
	int count;
	QStringList cols;

	m_sql.clear();
	m_sql += "SELECT " + (m_fields.isEmpty() ? "*" : m_fields.join(", ")) + " FROM " + m_table;
	if(!m_conditions.isEmpty())
	{
		m_sql += " WHERE " + m_conditions.join(" ");
	}
	if(!m_orders.isEmpty())
	{
		m_sql += " ORDER BY " + m_orders.join(", ");
	}
	m_sql += " LIMIT 1";

#ifdef SQL_DBG
		qDebug() << m_sql;
#endif
	CHECK(r)

		QSqlQuery query = m_db->exec();
	ok = query.exec(m_sql);
	SQLERR(r)

		record = query.record();
	count = record.count();
	for(int i = 0; i < count; i++)
		cols.push_back(record.fieldName(i));
	if(query.next())
	{
		record = query.record();
		ID_CONST_FOREACH(QStringList, cols)
		{
			r.insert(*itor, record.value(*itor));
		}
	}
	return r;
}

idSqlResultCol_t idDatabase::Col()
{
	idSqlResultCol_t r;
	bool ok;
	QSqlRecord record;

	m_sql.clear();
	m_sql += "SELECT " + (m_fields.isEmpty() ? "*" : m_fields.join(", ")) + " FROM " + m_table;
	if(!m_conditions.isEmpty())
	{
		m_sql += " WHERE " + m_conditions.join(" ");
	}
	if(!m_orders.isEmpty())
	{
		m_sql += " ORDER BY " + m_orders.join(", ");
	}
	if(m_start > 1 || m_limit > 0)
	{
		m_sql += " LIMIT " + QString::number(m_start);
		if(m_limit > 0)
			m_sql += ", " + QString::number(m_limit);
	}

#ifdef SQL_DBG
	qDebug() << m_sql;
#endif
	CHECK(r)

		QSqlQuery query = m_db->exec();
	ok = query.exec(m_sql);
	SQLERR(r)

	while(query.next())
	{
		record = query.record();
		r.push_back(record.value(0));
	}
	return r;
}

idSqlResult_t idDatabase::One()
{
	idSqlResult_t r;
	bool ok;
	QSqlRecord record;

	m_sql.clear();
	m_sql += "SELECT " + (m_fields.isEmpty() ? "*" : m_fields.join(", ")) + " FROM " + m_table;
	if(!m_conditions.isEmpty())
	{
		m_sql += " WHERE " + m_conditions.join(" ");
	}
	if(!m_orders.isEmpty())
	{
		m_sql += " ORDER BY " + m_orders.join(", ");
	}
	m_sql += " LIMIT 1";

#ifdef SQL_DBG
		qDebug() << m_sql;
#endif
	CHECK(r)

		QSqlQuery query = m_db->exec();
	ok = query.exec(m_sql);
	SQLERR(r)

	if(query.next())
	{
		record = query.record();
		r = record.value(0);
	}
	return r;
}

int idDatabase::Update(const QVariant &data)
{
	QStringList values;
	bool ok;

	m_sql.clear();
	if(data.canConvert<QVariantMap>())
	{
		QVariantMap map = data.toMap();
		ID_CONST_FOREACH(QVariantMap, map)
		{
			values.push_back(itor.key() + " = " + itor.value().toString());
		}
	}
	else if(data.canConvert<QVariantList>())
	{
		QVariantList list = data.toList();
		ID_CONST_FOREACH(QVariantList, list)
		{
			values.push_back(itor->toString());
		}
	}
	m_sql += "UPDATE " + m_table + " SET ";
	if(!values.isEmpty())
		m_sql += values.join(", ");
	else
		m_sql += data.toString();
	if(!m_conditions.isEmpty())
	{
		m_sql += " WHERE " + m_conditions.join(" ");
	}

#ifdef SQL_DBG
	qDebug() << m_sql;
#endif
	CHECK(-1)

		QSqlQuery query = m_db->exec();
	ok = query.exec(m_sql);
	SQLERR(-1)
		return query.numRowsAffected();
}

QVariant idDatabase::Insert(const QVariant &data)
{
	QStringList names;
	QStringList values;
	QVariant r;
	bool ok;

	m_sql.clear();
	if(data.canConvert<QVariantMap>())
	{
		QVariantMap map = data.toMap();
		ID_CONST_FOREACH(QVariantMap, map)
		{
			names.push_back(itor.key());
			values.push_back(itor.value().toString());
		}
	}
	else if(data.canConvert<QVariantList>())
	{
		QVariantList list = data.toList();
		ID_CONST_FOREACH(QVariantList, list)
		{
			values.push_back(itor->toString());
		}
	}
	m_sql += "INSERT INTO " + m_table;
	if(!names.isEmpty())
		m_sql += "(" + names.join(", ") + ")";
	m_sql += " VALUES (";
	if(!values.isEmpty())
		m_sql += values.join(", ");
	else
		m_sql += data.toString();
	m_sql += ")";

#ifdef SQL_DBG
	qDebug() << m_sql;
#endif
	CHECK(r)

		QSqlQuery query = m_db->exec();
	ok = query.exec(m_sql);
	SQLERR(r)
		r = query.lastInsertId();
	return r;
}

int idDatabase::Delete()
{
	bool ok;

	m_sql.clear();
	m_sql += "DELETE FROM " + m_table;
	if(!m_conditions.isEmpty())
	{
		m_sql += " WHERE " + m_conditions.join(" ");
	}

#ifdef SQL_DBG
	qDebug() << m_sql;
#endif
	CHECK(-1)

		QSqlQuery query = m_db->exec();
	ok = query.exec(m_sql);
	SQLERR(-1)
		return query.numRowsAffected();
}

QVariant idDatabase::Replace(const QVariant &data)
{
	QStringList names;
	QStringList values;
	QVariant r;
	bool ok;

	m_sql.clear();
	if(data.canConvert<QVariantMap>())
	{
		QVariantMap map = data.toMap();
		ID_CONST_FOREACH(QVariantMap, map)
		{
			names.push_back(itor.key());
			values.push_back(itor.value().toString());
		}
	}
	else if(data.canConvert<QVariantList>())
	{
		QVariantList list = data.toList();
		ID_CONST_FOREACH(QVariantList, list)
		{
			values.push_back(itor->toString());
		}
	}
	m_sql += "REPLACE INTO " + m_table;
	if(!names.isEmpty())
		m_sql += "(" + names.join(", ") + ")";
	m_sql += " VALUES (";
	if(!values.isEmpty())
		m_sql += values.join(", ");
	else
		m_sql += data.toString();
	m_sql += ")";

#ifdef SQL_DBG
	qDebug() << m_sql;
#endif
	CHECK(r)

		QSqlQuery query = m_db->exec();
	ok = query.exec(m_sql);
	SQLERR(r)
		r = query.lastInsertId();
	return r;
}

void idDatabase::SetErr(int err_no, const QString &error)
{
	m_errno = err_no;
	m_error = error;
}

int idDatabase::Errno() const
{
	return m_errno;
}

QString idDatabase::Error() const
{
	return m_error;
}

int idDatabase::Create(const QString &name, const QVariant &data, bool over)
{
	bool ok;
	QStringList values;

	if(over)
	{
		Drop(name);
	}

	m_sql.clear();
	m_sql = "CREATE TABLE IF NOT EXISTS " + name;
	if(data.canConvert<QVariantMap>())
	{
		QVariantMap map = data.toMap();
		ID_CONST_FOREACH(QVariantMap, map)
		{
			values.push_back(itor.key() + " " + itor.value().toString());
		}
	}
	else if(data.canConvert<QVariantList>())
	{
		QVariantList list = data.toList();
		ID_CONST_FOREACH(QVariantList, list)
		{
			values.push_back(itor->toString());
		}
	}
	m_sql += " (";
	if(!values.isEmpty())
		m_sql += values.join(", ");
	else
		m_sql += data.toString();
	m_sql += ")";

#ifdef SQL_DBG
	qDebug() << m_sql;
#endif
	CHECK(-1)

	QSqlQuery query = m_db->exec();
	ok = query.exec(m_sql);

	SQLERR(-1)
		return query.numRowsAffected();
}

int idDatabase::Drop(const QString &name)
{
	bool ok;

	m_sql.clear();
	m_sql = "DROP TABLE IF EXISTS " + name;
#ifdef SQL_DBG
	qDebug() << m_sql;
#endif
	CHECK(-1)

	QSqlQuery query = m_db->exec();
	ok = query.exec(m_sql);

	SQLERR(-1)
		return query.numRowsAffected();
}

bool idDatabase::IsConnected() const
{
	return m_db && m_db->isValid();
}

bool idDatabase::Transaction()
{
	bool ok;

	CHECK(false)
		ok = m_db->transaction();
	DBERR(false)

		return ok;
}

bool idDatabase::Commit()
{
	bool ok;

	CHECK(false)
		ok = m_db->commit();
	DBERR(false)

		return ok;
}

bool idDatabase::Rollback()
{
	bool ok;

	CHECK(false)
		ok = m_db->rollback();
	DBERR(false)

		return ok;
}

