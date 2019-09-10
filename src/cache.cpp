#include "cache.h"

#include <QDesktopServices>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QHash>

#include "id_std.h"

#define CHECK_CACHE_INIT_R(x) \
	if(_cache->m_path.isEmpty()) {\
		qWarning() << "[Warning]: Cache not inititalized."; \
		return x; \
	}

#define CHECK_CACHE_INIT \
	if(_cache->m_path.isEmpty()) {\
		qWarning() << "[Warning]: Cache not inititalized."; \
		return; \
	}

class idCacheLocal
{
	public:
		idCacheLocal();
		virtual ~idCacheLocal();
		QString GetCache(const QString &url) const;
		QString Cache(const QString &url, const QByteArray &data);
		qint64 CacheSize() const;
		int CacheCount() const;
		QString CachePath() const;
		void ClearCache();
		void RemoveCache(const QString &url);
		void SetCachePath(const QString &path = QString());
		void CleanCache();
		void CleanCacheDirectory() const;

	private:
		typedef QHash<QString, QString> idCacheMap_t;
		idCacheMap_t m_map;
		QString m_path;

		friend class idCache;
};

namespace id
{
	static idCacheLocal _cacheLocal;
	static idCacheLocal *_cache = &_cacheLocal;
}

using namespace id;

idCacheLocal::idCacheLocal()
{
}

idCacheLocal::~idCacheLocal()
{
	ID_DESTROY_DBG("idCacheLocal")
	CleanCache();
}

QString idCacheLocal::GetCache(const QString &url) const
{
	QString path = m_map.value(url);
	if(!path.isEmpty() && QFileInfo(path).isFile())
	{
		qDebug() << "Using cache: " << url << " -> " << path;
		return path;
	}
	return QString();
}

QString idCacheLocal::Cache(const QString &url, const QByteArray &data)
{
	int i;
	QString path = m_map.value(url);
	if(!path.isEmpty())
	{
		QFile file(path);
		if(file.exists() && file.size() == data.length())
		{
			return path;
		}
	}

	i = url.lastIndexOf("/");
	path = url.mid(i + 1);
	path = id::generate_file_name(path, _cache->m_path);
	id::file_put_contents(path, data);
#ifdef _DBG
	qDebug() << "Cache file: " << url << " -> " << path;
#endif
	return path;
}

qint64 idCacheLocal::CacheSize() const
{
	qint64 r;

	r = 0;
	ID_CONST_FOREACH(idCacheMap_t, m_map)
	{
		QFileInfo file(itor.value());
		if(file.exists())
		{
			r += file.size();
		}
	}
	return r;
}

int idCacheLocal::CacheCount() const
{
	return m_map.count();
}

QString idCacheLocal::CachePath() const
{
	return m_path;
}

void idCacheLocal::ClearCache()
{
	m_map.clear();
}

void idCacheLocal::RemoveCache(const QString &url)
{
	QString path = m_map.value(url);
	if(path.isEmpty())
	{
		qDebug() << "[Debug]: cache not exists -> " << url;
	}

	QFile file(path);
	if(file.exists())
	{
		if(!file.remove())
		{
			qWarning() << "[Debug]: file remove error -> " << file.fileName();
		}
	}
}

void idCacheLocal::SetCachePath(const QString &path)
{
	if(m_path != path)
	{
		m_path = path;
		id::mkdirs(m_path);
	}
}

void idCacheLocal::CleanCache()
{
	ID_CONST_FOREACH(idCacheMap_t, m_map)
	{
		QFile file(itor.value());
		if(file.exists())
		{
			if(!file.remove())
			{
				qWarning() << "[Debug]: file remove error -> " << file.fileName();
			}
		}
	}

	ClearCache();
}

void idCacheLocal::CleanCacheDirectory() const
{
	if(m_path.isEmpty()) return; // f^*k

	return;
	id::remove_all_file(m_path);
}



QString idCache::GetCache(const QString &url)
{
	CHECK_CACHE_INIT_R(QString())

		return _cache->GetCache(url);
}

QString idCache::Cache(const QString &url, const QByteArray &data)
{
	CHECK_CACHE_INIT_R(QString())

	return _cache->Cache(url, data);
}

qint64 idCache::CacheSize()
{
	CHECK_CACHE_INIT_R(0)

		return _cache->CacheSize();
}

int idCache::CacheCount()
{
	CHECK_CACHE_INIT_R(0)

	return _cache->CacheCount();
}

QString idCache::CachePath()
{
	CHECK_CACHE_INIT_R(QString())

	return _cache->CachePath();
}

void idCache::ClearCache()
{
	CHECK_CACHE_INIT

	_cache->ClearCache();
}

void idCache::RemoveCache(const QString &url)
{
	CHECK_CACHE_INIT

		_cache->RemoveCache(url);
}

void idCache::InitCache()
{
	_cache->SetCachePath(QDesktopServices::storageLocation(QDesktopServices::CacheLocation) + "/.cache");
	qDebug() << "[Debug]: Cache path -> " << _cache->m_path;
	_cache->CleanCacheDirectory();
}

void idCache::CleanCache()
{
	CHECK_CACHE_INIT

		_cache->CleanCache();
}
