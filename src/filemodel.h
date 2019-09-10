#ifndef _KARIN_FILEMODEL_H
#define _KARIN_FILEMODEL_H

#include "qmlmodel_base.h"

class QDir;

class idFileModel : public idQmlModel_base
{
	Q_OBJECT

		Q_PROPERTY(int filter READ Filter WRITE SetFilter NOTIFY filterChanged)
		Q_PROPERTY(int sort READ Sort WRITE SetSort NOTIFY sortChanged)
		Q_PROPERTY(QString path READ Path WRITE SetPath NOTIFY pathChanged)

	public:
		explicit idFileModel(QObject *parent = 0);
		virtual ~idFileModel();
		int Filter() const;
		int Sort() const;
		QString Path() const;
		void SetFilter(int value);
		void SetSort(int value);
		void SetPath(const QString &value);

		public Q_SLOTS:
			virtual void Restore();
		void Back();

Q_SIGNALS:
		void filterChanged(int filter);
		void sortChanged(int sort);
		void pathChanged(const QString &path);

	protected:
		virtual void InitRoleMap();

	private:
		enum idRole_e
		{
			Role_name = Qt::UserRole + 1,
			Role_path,
			Role_suffix, // if is directory, suffix is /
			Role_size,
			Role_mode,
			Role_owner,
			Role_group,

			Role_alphabet,
		};

	private:
		QDir *m_dir;
		QString m_path;
		int m_filter;
		int m_sort;

		Q_DISABLE_COPY(idFileModel)
};

#endif
