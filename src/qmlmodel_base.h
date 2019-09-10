#ifndef _KARIN_QMLMODEL_H
#define _KARIN_QMLMODEL_H

#include <QAbstractListModel>
#include <QList>

#include "id_std.h"

#define ID_QMLMODEL_INSERT_ROLE(clazz, role) m_roles.insert(clazz::Role_##role, #role);

class idDatabase;

class idQmlModel_base : public QAbstractListModel
{
	Q_OBJECT
		Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

	public:
		typedef QList<QVariantMap> idQmlModelData_t;

	public:
		explicit idQmlModel_base(QObject *parent = 0);
		virtual ~idQmlModel_base();
		virtual int rowCount(const QModelIndex &index = QModelIndex()) const;
		virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

		Q_INVOKABLE virtual QVariant GetValue(int index, const QString &name) const;
		Q_INVOKABLE virtual QVariantMap Get(int index) const;
		Q_INVOKABLE virtual QVariant SetValue(int index, const QString &name, const QVariant &data);
		// for like QDeclarativeListModel
		Q_INVOKABLE QVariant get(int index);
		template <class T>
		T GetValuev(int index, const QString &name) const;
		template <class T>
		T SetValuev(int index, const QString &name, const T &t);

		public Q_SLOTS:
		virtual void Clear();
		virtual void Restore() = 0;

	public:
		virtual idQmlModel_base & operator<<(const QVariantMap &data);
		virtual idQmlModel_base & Push_back(const QVariantMap &data);
		virtual void operator=(const idQmlModelData_t &data);
		virtual idQmlModel_base & Remove(int start, int count = 1);
		operator idQmlModelData_t &();

		public Q_SLOTS:
			void Update();

Q_SIGNALS:
		void countChanged(int count);

	protected:
		virtual void InitRoleMap() = 0;
		QHash<int, QByteArray> m_roles;

	private:
		idQmlModelData_t m_list;

	private:
		Q_DISABLE_COPY(idQmlModel_base)
};

template <class T>
T idQmlModel_base::GetValuev(int index, const QString &name) const
{
	return GetValue(index, name).value<T>();
}

template <class T>
T idQmlModel_base::SetValuev(int index, const QString &name, const T &t)
{
	QVariant r = SetValue(index, name, QVariant::fromValue<T>(t));
	return r.value<T>();
}

#endif
