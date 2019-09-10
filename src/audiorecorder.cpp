#include "audiorecorder.h"

#include <QFileInfo>
#include <QUrl>
#include <QDateTime>
#include <QDebug>

#include "cache.h"

	idAudioRecorder::idAudioRecorder(QObject *parent)
	: QObject(parent),
	m_recorder(0),
	m_audioSource(0),
	m_error(idAudioRecorder::NoError),
	m_state(idAudioRecorder::StoppedState),
	m_duration(0),
	m_encodingQuality(idAudioRecorder::HighQuality),
	m_bitRate(0),
	m_sampleRate(0),
	m_channelCount(1),
	m_codec("audio/AMR"),
	m_source(ID_DATA_VOICE_PATH "/"),
	m_filePath("")
{
	setObjectName("idAudioRecorder");
	m_prefix = objectName();

	m_settings.setCodec(m_codec);
	m_settings.setQuality(static_cast<QtMultimediaKit::EncodingQuality>(m_encodingQuality));
	m_settings.setChannelCount(m_channelCount);
	m_settings.setSampleRate(m_sampleRate);
	m_settings.setBitRate(m_bitRate);

	Init();
}

idAudioRecorder::~idAudioRecorder()
{
	ID_QOBJECT_DESTROY_DBG

		//Stop();
	if(m_recorder)
		m_recorder->deleteLater();
	if(m_audioSource)
		m_audioSource->deleteLater();
}

idAudioRecorder::idError_e idAudioRecorder::Error() const
{
	return m_error;
}

idAudioRecorder::idState_e idAudioRecorder::State() const
{
	return m_state;
}

QString idAudioRecorder::ErrorString() const
{
	return m_errorString;
}

qint64 idAudioRecorder::Duration() const
{
	return m_duration;
}

idAudioRecorder::idEncodingQuality_e idAudioRecorder::EncodingQuality() const
{
	return m_encodingQuality;
}

int idAudioRecorder::BitRate() const
{
	return m_bitRate;
}

int idAudioRecorder::SampleRate() const
{
	return m_sampleRate;
}

int idAudioRecorder::ChannelCount() const
{
	return m_channelCount;
}

QString idAudioRecorder::Codec() const
{
	return m_codec;
}

QString idAudioRecorder::Source() const
{
	return m_source;
}

QString idAudioRecorder::Prefix() const
{
	return m_prefix;
}

void idAudioRecorder::SetError(idAudioRecorder::idError_e value)
{
	if(m_error != value)
	{
		m_error = value;
		emit errorChanged(m_error);
	}
}

void idAudioRecorder::SetState(idAudioRecorder::idState_e value)
{
	if(m_state != value)
	{
		m_state = value;
		emit stateChanged(m_state);
	}
}

void idAudioRecorder::SetErrorString(const QString &value)
{
	if(m_errorString != value)
	{
		m_errorString = value;
		emit errorStringChanged(m_errorString);
	}
}

void idAudioRecorder::SetDuration(qint64 value)
{
	if(m_duration != value)
	{
		m_duration = value;
		emit durationChanged(m_duration);
	}
}

void idAudioRecorder::SetEncodingQuality(idAudioRecorder::idEncodingQuality_e value)
{
	if(m_encodingQuality != value)
	{
		m_encodingQuality = value;
		m_settings.setQuality(static_cast<QtMultimediaKit::EncodingQuality>(m_encodingQuality));
		emit encodingQualityChanged(m_encodingQuality);
	}
}

void idAudioRecorder::SetBitRate(int value)
{
	if(m_bitRate != value)
	{
		m_bitRate = value;
		m_settings.setBitRate(m_bitRate);
		emit bitRateChanged(m_bitRate);
	}
}

void idAudioRecorder::SetSampleRate(int value)
{
	if(m_sampleRate != value)
	{
		m_sampleRate = value;
		m_settings.setSampleRate(m_sampleRate);
		emit sampleRateChanged(m_sampleRate);
	}
}

void idAudioRecorder::SetChannelCount(int value)
{
	if(m_channelCount != value)
	{
		m_channelCount = value;
		m_settings.setChannelCount(m_channelCount);
		emit channelCountChanged(m_channelCount);
	}
}

void idAudioRecorder::SetCodec(const QString &value)
{
	if(m_codec != value)
	{
		m_codec = value;
		m_settings.setCodec(m_codec);
		emit codecChanged(m_codec);
	}
}

void idAudioRecorder::SetSource(const QString &value)
{
	if(m_source != value)
	{
		m_source = value;
		emit sourceChanged(m_source);
	}
}

void idAudioRecorder::SetPrefix(const QString &value)
{
	if(m_prefix != value)
	{
		m_prefix = value;
		emit prefixChanged(m_prefix);
	}
}

void idAudioRecorder::Start()
{
	if(!m_recorder)
		Init();
	m_recorder->setEncodingSettings(m_settings);
	GetFileStorePath();
	m_recorder->setOutputLocation(QUrl
#if 0
			::fromLocalFile
#endif
			(m_filePath));
	qDebug() << "[Debug]: idAudioRecorder start -> " << m_filePath;
	m_recorder->record();
}

void idAudioRecorder::Stop()
{
	if(!m_recorder)
		return;
	m_recorder->stop();
	qDebug() << "[Debug]: idAudioRecorder stop -> " << m_filePath;
}

void idAudioRecorder::Pause()
{
	if(!m_recorder)
		return;
	m_recorder->pause();
}

void idAudioRecorder::Init()
{
	if(!m_audioSource)
		m_audioSource = new QAudioCaptureSource;
	if(!m_recorder)
		m_recorder = new QMediaRecorder(m_audioSource);

	m_recorder->setEncodingSettings(m_settings);

	connect(m_recorder, SIGNAL(durationChanged(qint64)), this, SLOT(durationChanged_slot(qint64)));
	connect(m_recorder, SIGNAL(error(QMediaRecorder::Error)), this, SLOT(errorChanged_slot(QMediaRecorder::Error)));
	connect(m_recorder, SIGNAL(stateChanged(QMediaRecorder::State)), this, SLOT(stateChanged_slot(QMediaRecorder::State)));
}

void idAudioRecorder::durationChanged_slot(qint64 duration)
{
	SetDuration(duration);
}

void idAudioRecorder::errorChanged_slot(QMediaRecorder::Error err)
{
	SetError(static_cast<idAudioRecorder::idError_e>(err));
	SetErrorString(m_recorder->errorString());
	emit error(m_error, m_errorString);
}

void idAudioRecorder::stateChanged_slot(QMediaRecorder::State state)
{
	SetState(static_cast<idAudioRecorder::idState_e>(state));
	if(state == QMediaRecorder::StoppedState)
	{
		emit audioRecorded(m_recorder->outputLocation().toString());
	}
}

QStringList idAudioRecorder::GetSupportedAudioCodecs()
{
	QStringList r;

	if(!m_recorder)
		Init();

	r = m_recorder->supportedAudioCodecs();
	//qDebug()<<r;
	return r;
}

QList<int> idAudioRecorder::GetSupportedAudioSampleRates()
{
	QList<int> r;

	if(!m_recorder)
		Init();

	r = m_recorder->supportedAudioSampleRates();
	//qDebug()<<r;
	return r;
}

void idAudioRecorder::GetFileStorePath()
{
	if(!m_source.isEmpty())
	{
		QFileInfo info(m_source);
		if(info.exists())
		{
			if(info.isDir())
				m_filePath = QString("%1/%2_%3.%4").arg(info.absoluteFilePath()).arg(Prefix()).arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")).arg(GetFileSuffix());
			else
				m_filePath = m_source;
		}
		else
		{
			if(m_source.endsWith('/'))
				m_filePath = QString("%1/%2_%3.%4").arg(info.absoluteFilePath()).arg(Prefix()).arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")).arg(GetFileSuffix());
			else
				m_filePath = m_source;
		}
	}
	else
	{
		m_filePath = QString("%1/%2_%3.%4").arg(idCache::CachePath()).arg(Prefix()).arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")).arg(GetFileSuffix());
	}
	id::mkdirs(QFileInfo(m_filePath).absolutePath());
}

QString idAudioRecorder::GetFileSuffix()
{
	// audio/AAC,audio/speex,audio/PCM,audio/AMR,audio/AMR-WB,audio/FLAC
	if(m_codec.compare("audio/AAC", Qt::CaseInsensitive) == 0)
		return "aac";
	else if(m_codec.compare("audio/speex", Qt::CaseInsensitive) == 0)
		return "speex";
	else if(m_codec.compare("audio/PCM", Qt::CaseInsensitive) == 0)
		return "wav";
	else if(m_codec.compare("audio/AMR", Qt::CaseInsensitive) == 0)
		return "amr";
	else if(m_codec.compare("audio/AAC-WB", Qt::CaseInsensitive) == 0)
		return "amr";
	else if(m_codec.compare("audio/FLAC", Qt::CaseInsensitive) == 0)
		return "flac";
	else
		return "mp3";
}
