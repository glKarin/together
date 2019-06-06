#ifndef UTILITY_H
#define UTILITY_H

#include <QObject>
#include <QVariant>

class QSettings;
class QDeclarativeEngine;

class idUtility : public QObject
{
    Q_OBJECT
			Q_PROPERTY(int dev READ Dev WRITE SetDev NOTIFY devChanged)
			Q_PROPERTY(idRunMode_e runMode READ RunMode FINAL)
			Q_ENUMS(idRunMode_e)

	public:
			enum idRunMode_e
			{
				RunMode_Not_Run_On_Background = 0,
				RunMode_Only_Hide_Window,
				RunMode_Close_Window,
			};

public:
    virtual ~idUtility();
    static idUtility * Instance();
    void SetEngine(QDeclarativeEngine *e);
    QDeclarativeEngine * Engine();
    template <class T> T GetSetting(const QString &name);
    template <class T> void SetSetting(const QString &name, const T &value);
		int Dev() const;
		void SetDev(int d);
		idRunMode_e RunMode() const;

    Q_INVOKABLE QVariant GetSetting(const QString &name);
    Q_INVOKABLE void SetSetting(const QString &name, const QVariant &value);
    Q_INVOKABLE void OpenPlayer(const QString &url, int t = 0) const;
    Q_INVOKABLE void CopyToClipboard(const QString &text) const;
    Q_INVOKABLE QVariant ResetSetting(const QString &name = QString());
    Q_INVOKABLE void Print_r(const QVariant &v) const;
    Q_INVOKABLE void SetRequestHeaders(const QVariant &v);
    Q_INVOKABLE void SetRequestHeader(const QString &k, const QString &v);
    Q_INVOKABLE QString Sign(const QVariantMap &args, const QString &suffix = QString(), const QVariantMap &sysArgs = QVariantMap()) const;
		Q_INVOKABLE QVariant Get(const QString &name = QString()) const;
		Q_INVOKABLE QVariant Changelog(const QString &version = QString()) const;
		Q_INVOKABLE QString Uncompress(const QString &src, int windowbits = 32 + 15) const;
		Q_INVOKABLE QVariant XML_Parse(const QString &xml) const;
		Q_INVOKABLE QVariant GetDefaultSetting(const QString &name = QString()) const;
		Q_INVOKABLE QString FormatUrl(const QString &u) const;
		Q_INVOKABLE qint64 System(const QString &path, const QVariant &args = QVariant(), bool async = false) const;
		Q_INVOKABLE void CheckUpdate();
		Q_INVOKABLE QVariant ParseUrl(const QString &url, const QString &part = QString()) const;
		Q_INVOKABLE QVariant GetCookie(const QString &url) const;
		Q_INVOKABLE QString CacheFile(const QString &b64, const QString &name = QString()) const;
    
Q_SIGNALS:
		void devChanged(int dev);
		void hasUpdate(int version);

private:
    explicit idUtility(QObject *parent = 0);
    void Init();

private:
    QSettings *oSettings;
    QDeclarativeEngine *oEngine;
		int iDev;
		idRunMode_e eRunMode;

    Q_DISABLE_COPY(idUtility)
    
};

template <class T> T idUtility::GetSetting(const QString &name)
{
	QVariant v = GetSetting(name);
	if(v.canConvert<T>())
		return v.value<T>();
	return T();
}

template <class T> void idUtility::SetSetting(const QString &name, const T &value)
{
	QVariant v(value);
	SetSetting(name, v);
}

#endif // UTILITY_H
