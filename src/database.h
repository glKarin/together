#ifndef _KARIN_DATABASE_H
#define _KARIN_DATABASE_H

#include <QVariant>
#include <QStringList>

#define ID_SQL_QUOTE_VALUE(v) ("'" + (v) + "'")

class QSqlDatabase;

typedef QVariant idSqlResult_t;
typedef QVariantMap idSqlResultRow_t;
typedef QVariantList idSqlResultCol_t;
typedef QList<idSqlResultRow_t> idSqlResultList_t;

class idDatabase
{
	public:
		idDatabase();
		virtual ~idDatabase();
		void Reset();
		int Errno() const;
		QString Error() const;
		idDatabase & Table(const QString &table);
		idDatabase & Fields(const QStringList &list);
		idDatabase & AddField(const QString &name, const QString &alias = QString());
		idDatabase & And(const QString &name, const QVariant &value = QVariant(), const QString &op = "=", int type = 0);
		idDatabase & Or(const QString &name, const QVariant &value = QVariant(), const QString &op = "=", int type = 0);
		idDatabase & Orders(const QStringList &list);
		idDatabase & AddOrder(const QString &name, const QString &t = "ASC");
		idDatabase & Limit(int start = 1, int limit = -1);
		idDatabase & Page(int start = 1, int limit = 20);
		QString SQL() const;

		idSqlResultList_t Select();
		idSqlResultRow_t Row();
		idSqlResultCol_t Col();
		idSqlResult_t One();
		int Count();
		int Update(const QVariant &data);
		QVariant Insert(const QVariant &data);
		QVariant Replace(const QVariant &data);
		int Delete();
		bool Connect(const QString &name, const QString &user = QString(), const QString &password = QString());
		void Disconnect();
		bool IsConnected() const;
		int Create(const QString &name, const QVariant &data, bool over = false);
		int Drop(const QString &name);
		bool Transaction();
		bool Commit();
		bool Rollback();

	private:
		void SetErr(int err_no, const QString &error);
		bool Check() const;

	private:
		QSqlDatabase *m_db;
		int m_errno;
		QString m_error;
		QString m_table;
		QStringList m_fields;
		QStringList m_conditions;
		QStringList m_orders;
		int m_start;
		int m_limit;
		QString m_sql;
};

#endif
