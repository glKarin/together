#ifndef _KARIN_QMLIMAGE_H
#define _KARIN_QMLIMAGE_H

#include <QDeclarativeItem>

class QNetworkAccessManager;
class QNetworkReply;

class idQmlImage : public QDeclarativeItem
{
	Q_OBJECT
		Q_PROPERTY(QUrl source READ Source WRITE SetSource NOTIFY sourceChanged)
		Q_PROPERTY(bool asynchronous READ Asynchronous WRITE SetAsynchronous NOTIFY asynchronousChanged)
		Q_PROPERTY(bool cache READ Cache WRITE SetCache NOTIFY cacheChanged)
		Q_PROPERTY(bool mirror READ Mirror WRITE SetMirror NOTIFY mirrorChanged)
		Q_PROPERTY(bool smooth READ Smooth WRITE SetSmooth NOTIFY smoothChanged)
		Q_PROPERTY(QSize sourceSize READ SourceSize WRITE SetSourceSize NOTIFY sourceSizeChanged)
		Q_PROPERTY(idFillMode_e fillMode READ FillMode WRITE SetFillMode NOTIFY fillModeChanged)

		Q_PROPERTY(qreal progress READ Progress NOTIFY progressChanged)
		Q_PROPERTY(qreal paintedHeight READ PaintedHeight NOTIFY paintedHeightChanged)
		Q_PROPERTY(qreal paintedWidth READ PaintedWidth NOTIFY paintedWidthChanged)
		Q_PROPERTY(idStatus_e status READ Status NOTIFY statusChanged)

		Q_ENUMS(idStatus_e)
		Q_ENUMS(idFillMode_e)

	public:
		enum idStatus_e
		{
			Null = 0,
			Ready,
			Loading,
			Error,
		};
		enum idFillMode_e
		{
			Stretch = 0,
			PreserveAspectFit,
			PreserveAspectCrop,
			Tile,
			TileVertically,
			TileHorizontally,
		};

	public:
		explicit idQmlImage(QDeclarativeItem *parent = 0);
		virtual ~idQmlImage();
		virtual void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget = 0);

		QUrl Source() const;
		bool Asynchronous() const;
		bool Cache() const;
		bool Mirror() const;
		bool Smooth() const;
		idStatus_e Status() const;
		idFillMode_e FillMode() const;
		qreal PaintedHeight() const;
		qreal PaintedWidth() const;
		qreal Progress() const;
		QSize SourceSize() const;

		void SetSource(const QUrl &value);
		void SetSourceSize(const QSize &value);
		void SetSmooth(bool value);
		void SetMirror(bool value);
		void SetCache(bool value);
		void SetAsynchronous(bool value);
		void SetFillMode(idFillMode_e value);

		public Q_SLOTS:
			void Dump(const QString &path);

Q_SIGNALS:
		void sourceChanged(const QUrl &source);
		void statusChanged(idStatus_e status);
		void cacheChanged(bool cache);
		void mirrorChanged(bool mirror);
		void asynchronousChanged(bool asynchronous);
		void smoothChanged(bool smooth);
		void sourceSizeChanged(const QSize &sourceSize);
		void fillModeChanged(idFillMode_e fillMode);
		void paintedHeightChanged(qreal paintedHeight);
		void paintedWidthChanged(qreal paintedWidth);
		void progressChanged(qreal progress);

		private Q_SLOTS:
			void downloadProgress_slot(qint64 read, qint64 total);
		void finished_slot();
		void readyRead_slot();

	private:
		QNetworkAccessManager * Manager();
		void LoadImageData(bool remote = false);
		void Init();
		void InitLoad();
		void InitFromNetwork(const QUrl &url = QUrl());
		void InitFromLocal(const QString &path = QString());
		void InitFromBase64(const QString &data);
		void SetStatus(idStatus_e value);
		void SetPaintedWidth(qreal value);
		void SetPaintedHeight(qreal value);
		void SetProgress(qreal value);

	private:
		bool m_asynchronous;
		bool m_cache;
		idFillMode_e m_fillMode;
		bool m_mirror;
		qreal m_paintedHeight;
		qreal m_paintedWidth;
		qreal m_progress;
		bool m_smooth;
		QUrl m_source;
		QSize m_sourceSize;
		idStatus_e m_status;

		QByteArray m_data;
		int m_compressed;
		QImage m_image;
		QNetworkReply *m_reply;

		Q_DISABLE_COPY(idQmlImage)
};

#endif
