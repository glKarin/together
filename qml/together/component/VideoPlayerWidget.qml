import QtQuick 1.1
import com.nokia.meego 1.1
import QtMobility.systeminfo 1.1
import QtMultimediaKit 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	property alias source: video.source;
	property bool bLoop: false;
	property bool bAutoPlay: true;
	property alias videoItem: video;

	signal download(string source);
	signal endOfMedia();
	objectName: "idVideoPlayerWidget";

	Video {
		id: video;
		anchors.fill: parent;
		onError:{
			if(error !== Video.NoError){
				console.log("[Qml]: " + error + " -> " + errorString);
				video.stop();
				source = "";
				position = 0;
			}
		}
		onStatusChanged: {
			if(status === Video.EndOfMedia)
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
		focus: true
		onPlayingChanged: {
			screensaver.setScreenSaverDelayed(playing);
		}

		DeviceInfo {
			id: devinfo;
		}
		ScreenSaver{
			id: screensaver;
			//screenSaverDelayed: video.playing && !video.paused;
		}

		function _Toggle(on)
		{
			if(on === undefined)
			{
				playing = true;
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

	Item{
		id: control;
		anchors.margins: constants._iSpacingSuper;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		height: constants._iSizeXL;
		z: 1;
		visible: opacity > 0.0;
		clip: true;
		state: constants._sHideState;

		states: [
			State{
				name: constants._sShowState;
				PropertyChanges{
					target: control;
					opacity: 1.0;
				}
			},
			State{
				name: constants._sHideState;
				PropertyChanges{
					target: control;
					opacity: 0.0;
				}
			}
		]

		transitions: [
			Transition{
				from: constants._sHideState;
				to: constants._sShowState;
				NumberAnimation{
					target: control;
					property: "opacity";
					duration: 500;
					easing.type: Easing.OutExpo;
				}
			},
			Transition{
				from: constants._sShowState;
				to: constants._sHideState;
				NumberAnimation{
					target: control;
					property: "opacity";
					duration: 500;
					easing.type: Easing.InExpo;
				}
			}
		]

		function _Toggle(on)
		{
			if(on === undefined)
			{
				if(state === constants._sHideState) state = constants._sShowState;
				else if(state === constants._sShowState) state = constants._sHideState;
			}
			else
			{
				state = on ? constants._sShowState : constants._sHideState;
			}
		}

		ToolIcon{
			id: play;
			iconId: video.paused || !video.playing ? "toolbar-mediacontrol-play" : "toolbar-mediacontrol-pause";
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
			enabled: video.source != "";
			onClicked: {
				timer.restart();
				video._Toggle();
			}
		}

		ProgressBar {
			id: progressBar;
			anchors.left: play.right;
			anchors.right: stop.left;
			anchors.verticalCenter: parent.verticalCenter;
			minimumValue: 0;
			maximumValue: video.duration;
			value: video.position;
			MouseArea{
				function __Seek(mouse_x)
				{
					timer.restart();
					video._SetPercent(mouse_x / width);
				}
				anchors.centerIn: parent;
				enabled: video.duration !== 0 && video.seekable;
				width: parent.width;
				height: 8 * parent.height;
				onClicked: {
					__Seek(mouse.x);
				}
				onPositionChanged:{
					if(pressed)
					{
						__Seek(mouse.x);
					}
				}
			}
		}

		Row{
			anchors.left: progressBar.left;
			anchors.right: progressBar.right;
			anchors.top: parent.top;
			anchors.bottom: progressBar.top;
			clip: true;
			Text{
				width: parent.width / 2;
				height: parent.height;
				color: constants._cLightColor;
				horizontalAlignment: Text.AlignLeft;
				verticalAlignment: Text.AlignVCenter;
				font.pixelSize: constants._iFontMedium;
				text: parent.visible ? Util.FormatDuration(video.position / 1000) : "";
			}

			Text{
				id: durationtext;
				width: parent.width / 2;
				height: parent.height;
				color: constants._cLightColor;
				horizontalAlignment: Text.AlignRight;
				verticalAlignment: Text.AlignVCenter;
				font.pixelSize: constants._iFontMedium;
				text: parent.visible ? Util.FormatDuration(video.duration / 1000) : "";
			}
		}

		ToolIcon{
			id: stop;
			iconId: "toolbar-mediacontrol-stop";
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			enabled: video.source != "";
			onClicked: {
				timer.restart();
				root._Stop();
			}
		}

		Timer{
			id: timer;
			interval: 8000;
			repeat: false;
			running: control.state === constants._sShowState;
			onTriggered: {
				control._Toggle(false);
			}
		}
	}

	BusyIndicator{
		id: indicator;
		anchors.centerIn: parent;
		z: 2;
		platformStyle: BusyIndicatorStyle{
			size: "large";
			inverted: true;
		}
		visible: video.playing && video.bufferProgress !== 1.0;
		running: visible;
	}

	MouseArea{
		anchors.fill: parent;
		onClicked: {
			control._Toggle();
		}
		onDoubleClicked: {
			video._Toggle();
		}
	}

	function _Load(src, pos)
	{
		video.source = src;
		if(video.source != "")
		{
			video._Play();

			if(pos && video.seekable) video.position = pos;
		}
	}

	function _Stop()
	{
		video.stop();
		video.position = 0;
	}

	function _Play()
	{
		if(video.source != "")
		video._Play();
	}

	function _Pause()
	{
		if(video.playing)
		video._Pause();
	}

	function _Close()
	{
		video.stop();
		video.source = "";
	}

	function _SetPosition(pos)
	{
		if(!video.seekable)
		return;

		if(video.source != "")
		{
			var p = pos === undefined ? 0 : pos;
			video.position = p;
		}
	}

	Connections{
		target: Qt.application;
		onActiveChanged: {
			if(!Qt.application.active) _Pause();
		}
	}

	Component.onDestruction: {
		_Close();
	}
}
