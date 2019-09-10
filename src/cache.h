#ifndef _KARIN_CACHE_H
#define _KARIN_CACHE_H

#include <qglobal.h>

class QString;
class QByteArray;

class idCache
{
	public:
		static QString GetCache(const QString &url);
		static QString Cache(const QString &url, const QByteArray &data);
		static qint64 CacheSize();
		static int CacheCount();
		static QString CachePath();
		static void ClearCache();
		static void RemoveCache(const QString &url);
		static void InitCache();
		static void CleanCache();

	private:
		idCache();
		virtual ~idCache();
};

#endif
