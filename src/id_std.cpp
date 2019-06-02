#include "id_std.h"

#include <zlib.h>
#include <QCryptographicHash>
#include <QFile>
#include <QDebug>
#include <QtXml>

namespace id
{
	QString md5(const QString &src)
	{
		QByteArray r = QCryptographicHash::hash(QByteArray().append(src), QCryptographicHash::Md5);
		return r.toHex();
	}

	QString md5_b64(const QString &src)
	{
		QByteArray r = QCryptographicHash::hash(QByteArray().append(src), QCryptographicHash::Md5);
		return r.toBase64();
	}

	int iduncompress(QByteArray *dst, const QByteArray &data, int windowbits)
	{
    int ret;
    z_stream strm;
    static const int CHUNK_SIZE = 1024;
    char out[CHUNK_SIZE];

		if(!dst)
			return 1;
    if (data.size() <= 4){
        qWarning("gUncompress: Input data is truncated");
        return 2;
    }
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = data.size();
    strm.next_in = (Bytef*)(data.data());

    ret = inflateInit2(&strm, windowbits);
    if (ret != Z_OK)
        return 3;

    do {
        strm.avail_out = CHUNK_SIZE;
        strm.next_out = (Bytef*)(out);

        ret = inflate(&strm, Z_NO_FLUSH);
        //Q_ASSERT(ret != Z_STREAM_ERROR);
        if(ret == Z_STREAM_ERROR)
					return 5;

        switch (ret){
        case Z_NEED_DICT:
            ret = Z_DATA_ERROR;
        case Z_DATA_ERROR:
        case Z_MEM_ERROR:
            (void)inflateEnd(&strm);
            return 6;
        }
        dst->append(out, CHUNK_SIZE - strm.avail_out);
    } while (strm.avail_out == 0);

    inflateEnd(&strm);
    return 0;
	}

	static void qvariant_from_xml_r(const QDomElement &element, QVariantMap &map)
	{
		QVariantMap attrMap;
		QVariantList child;

		map.insert("tag", element.tagName());
		QDomNamedNodeMap attrs = element.attributes();
		for(int i = 0; i < attrs.length(); i++)
		{
			QDomNode d = attrs.item(i);
			if(!d.isAttr())
				continue;
			QDomAttr a = d.toAttr();
			attrMap.insert(a.name(), a.value());
		}
		map.insert("params", attrMap);
		for(QDomNode node = element.firstChild(); !node.isNull(); node = node.nextSibling())
		{
			QVariant v;
			if(node.isElement())
			{
				QDomElement e = node.toElement();
				QVariantMap m;
				qvariant_from_xml_r(e, m);
				v.setValue(m);
			}
			else if(node.isText())
			{
				QString str = node.toText().data();
				v.setValue(str);
			}
			child.push_back(v);
		}
		if(child.size() == 0)
			map.insert("children", QVariant());
		else if(child.size() == 1)
		{
			if(child[0].canConvert<QString>())
				map.insert("children", child[0].toString());
			else
				map.insert("children", child);
		}
		else
			map.insert("children", child);
	}

	QVariant qvariant_from_xml(const QString &xml)
	{
		QString errorMsg;
		int errorLine;
		int errorColumn;
//		qDebug() << xml;
		QDomDocument doc;
		QVariant r;

		errorLine = 0;
		errorColumn = 0;
		if(!doc.setContent(xml, &errorMsg, &errorLine, &errorColumn))
			qDebug() << QString("[%1]: %2 -> %3[line: %4, column: %5]").arg(QObject::tr("ERROR")).arg(QObject::tr("Parse XML error")).arg(errorMsg).arg(errorLine).arg(errorColumn);
		else
		{
			QVariantMap m;
			QDomElement root = doc.documentElement();
			qvariant_from_xml_r(root, m);
			r.setValue(m);
			// qDebug() << m;
		}
		return r;
	}

	bool file_put_contents(const QString &file, const QByteArray &data, int mode)
	{
		bool o;

		if(file.isEmpty())
			return false;
		if(data.isEmpty())
			return false;

		QFile f(file);
		o = false;
		if(mode == 1)
			o = f.open(QIODevice::Append);
		else
			o = f.open(QIODevice::WriteOnly);
		if(!o)
			return false;

		o = (f.write(data) != -1);

		f.flush();
		f.close();

		return o;
	}
}

