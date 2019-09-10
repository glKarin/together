#ifndef _KARIN_TRANSFERRECORD_H
#define _KARIN_TRANSFERRECORD_H

#include "qmlmodel_base.h"

#include "id_std.h"

class idDatabase;
class idTransferTask_base;

class idTransferRecord : public idQmlModel_base
{
	Q_OBJECT
		Q_PROPERTY(idMode_e mode READ Mode WRITE SetMode NOTIFY modeChanged)
		Q_ENUMS(idMode_e)

	public:
		enum idMode_e
		{
			Mode_All = 0,
			Mode_Download,
			Mode_Upload,
		};

	public:
		explicit idTransferRecord(QObject *parent = 0);
		virtual ~idTransferRecord();
		idMode_e Mode() const;
		void SetMode(idMode_e mode);
		static void Dump(idTransferTask_base *task);

		public Q_SLOTS:
		virtual void Restore();
		void Clean(int mode = 1);
		void Delete(int id, bool file = false);

Q_SIGNALS:
		void modeChanged(int mode);

	private:
		enum idRole_e
		{
			Role_id = Qt::UserRole + 1,
			Role_name,
			Role_size,
			Role_path,
			Role_updated_time,
			Role_type,
			Role_mode,

			Role_date,
		};
		virtual void InitRoleMap();
		void InitDBTable();

	private:
		idDatabase *m_db;
		idMode_e m_mode;
		QString m_tableName;

	private:
		Q_DISABLE_COPY(idTransferRecord)
};

#endif
