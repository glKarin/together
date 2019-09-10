import QtQuick 1.1
import QtMultimediaKit 1.1
import QtMobility.systeminfo 1.1
import "../../js/main.js" as Script

Item{
	id: root;
	property alias source: audio.source;
	property alias audioItem: audio;
	property bool bLoop: false;
	property bool bAutoPlay: true;

	signal endOfMedia();
	
	objectName: "idVoiceWidget";

	visible: false;
	width: 0;
	height: 0;
	clip: true;

	Audio{
		id: audio;
		onError:{
			if(error !== Audio.NoError){
				console.log("[Qml]: " + error + " -> " + errorString);
				audio.stop();
				source = "";
				position = 0;
			}
		}
		onStatusChanged: {
			if(status === Audio.EndOfMedia)
			{
				position = 0;
				root.endOfMedia();
				if(root.bLoop) _Play();
			}
		}
		onSourceChanged: {
			if(source != "" && root.bAutoPlay)
			_Play();
		}

		volume: devinfo.voiceRingtoneVolume / 100;
		function _Toggle(on)
		{
			if(on === undefined)
			{
				playing = true;
				if(position === 0)
				paused = false;
				else
				paused = !paused;
			}
			else
			{
				if(on) _Play();
				else _Pause();
			}
		}
		function _SetPercent(per)
		{
			if(!seekable)
			return;

			if(source != "")
			{
				var p = duration * per;
				position = p;
			}
		}

		function _Play()
		{
			playing = true;
			paused = false;
		}
		function _Pause()
		{
			paused = true;
		}

	}

	Connections{
		target: Qt.application;
		onActiveChanged: {
			if(!Qt.application.active) _Pause();
		}
	}

	DeviceInfo {
		id: devinfo;
	}

	function _Load(src, pos)
	{
		if(audio.source == src)
		{
			audio._Toggle();
			return;
		}
		audio.source = src;
		if(audio.source != "")
		{
			audio._Play();

			if(pos && audio.seekable) audio.position = pos;
		}
	}

	function _Stop()
	{
		audio.stop();
		audio.position = 0;
	}

	function _Play()
	{
		if(audio.source != "")
		audio._Play();
	}

	function _Pause()
	{
		if(audio.playing)
		audio._Pause();
	}

	function _Close()
	{
		audio.stop();
		audio.source = "";
	}

	function _SetPosition(pos)
	{
		if(!audio.seekable)
		return;

		if(audio.source != "")
		{
			var p = pos === undefined ? 0 : pos;
			audio.position = p;
		}
	}

	Component.onDestruction: {
		_Close();
	}
}
