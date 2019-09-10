#ifndef _KARIN_AUDIORECORDER_H
#define _KARIN_AUDIORECORDER_H

#include <QObject>
#include <QMediaRecorder>
#include <QAudioCaptureSource>

#include "id_std.h"

#define ID_DATA_VOICE_PATH ID_DATA_PATH "/voice_record"

class idAudioRecorder : public QObject
{

	Q_OBJECT
		Q_PROPERTY(idError_e error READ Error NOTIFY errorChanged)
		Q_PROPERTY(idState_e state READ State NOTIFY stateChanged)
		Q_PROPERTY(QString errorString READ ErrorString NOTIFY errorStringChanged)
		Q_PROPERTY(qint64 duration READ Duration NOTIFY durationChanged)
		Q_PROPERTY(idEncodingQuality_e encodingQuality READ EncodingQuality WRITE SetEncodingQuality NOTIFY encodingQualityChanged)
		Q_PROPERTY(int bitRate READ BitRate WRITE SetBitRate NOTIFY bitRateChanged)
		Q_PROPERTY(int sampleRate READ SampleRate WRITE SetSampleRate NOTIFY sampleRateChanged)
		Q_PROPERTY(int channelCount READ ChannelCount WRITE SetChannelCount NOTIFY channelCountChanged)
		Q_PROPERTY(QString codec READ Codec WRITE SetCodec NOTIFY codecChanged)
		Q_PROPERTY(QString source READ Source WRITE SetSource NOTIFY sourceChanged)
		Q_PROPERTY(QString prefix READ Prefix WRITE SetPrefix NOTIFY prefixChanged)
		Q_ENUMS(idError_e)
		Q_ENUMS(idState_e)
		Q_ENUMS(idEncodingQuality_e)

	public:
		enum idError_e
		{
			NoError = QMediaRecorder::NoError,
			ResourceError = QMediaRecorder::ResourceError,
			FormatError = QMediaRecorder::FormatError,
		};

		enum idState_e
		{
			StoppedState = QMediaRecorder::StoppedState,
			RecordingState = QMediaRecorder::RecordingState,
			PausedState = QMediaRecorder::PausedState,
		};
		
		enum idEncodingQuality_e
		{
			VeryLowQuality = QtMultimediaKit::VeryLowQuality,
			LowQuality = QtMultimediaKit::LowQuality,
			NormalQuality = QtMultimediaKit::NormalQuality,
			HighQuality = QtMultimediaKit::HighQuality,
			VeryHighQuality = QtMultimediaKit::VeryHighQuality,
		};

	public:
		explicit idAudioRecorder(QObject *parent = 0);
		virtual ~idAudioRecorder();
		idError_e Error() const;
		idState_e State() const;
		QString ErrorString() const;
		qint64 Duration() const;
		idEncodingQuality_e EncodingQuality() const;
		int BitRate() const;
		int SampleRate() const;
		int ChannelCount() const;
		QString Codec() const;
		QString Source() const;
		QString Prefix() const;

		void SetError(idError_e value);
		void SetState(idState_e value);
		void SetErrorString(const QString &value);
		void SetDuration(qint64 value);
		void SetEncodingQuality(idEncodingQuality_e value);
		void SetBitRate(int value);
		void SetSampleRate(int value);
		void SetChannelCount(int value);
		void SetCodec(const QString &value);
		void SetSource(const QString &value);
		void SetPrefix(const QString &value);

		Q_INVOKABLE QStringList GetSupportedAudioCodecs();
		Q_INVOKABLE QList<int> GetSupportedAudioSampleRates();

		public Q_SLOTS:
			void Start();
		void Stop();
		void Pause();

Q_SIGNALS:
		void errorChanged(idError_e error);
		void stateChanged(idState_e state);
		void errorStringChanged(const QString &errorString);
		void durationChanged(qint64 duration);
		void encodingQualityChanged(idEncodingQuality_e encodingQuality);
		void bitRateChanged(int bitRate);
		void sampleRateChanged(int sampleRate);
		void channelCountChanged(int channelCount);
		void codecChanged(const QString &codec);
		void audioRecorded(const QString &filePath);
		void sourceChanged(const QString &source);
		void prefixChanged(const QString &prefix);
		void error(idError_e error, const QString &errorString);

	private:
		void Init();
		void GetFileStorePath();
		QString GetFileSuffix();

	private Q_SLOTS:
		void durationChanged_slot(qint64 duration = 0);
		void errorChanged_slot(QMediaRecorder::Error error);
		void stateChanged_slot(QMediaRecorder::State state);

	private:
		QMediaRecorder *m_recorder;
		QAudioCaptureSource *m_audioSource;
		QAudioEncoderSettings m_settings;
		idError_e m_error;
		idState_e m_state;
		QString m_errorString;
		qint64 m_duration;
		idEncodingQuality_e m_encodingQuality;
		int m_bitRate;
		int m_sampleRate;
		int m_channelCount;
		QString m_codec;
		QString m_source;
		QString m_prefix;

		QString m_filePath;

		Q_DISABLE_COPY(idAudioRecorder)
};

#endif
