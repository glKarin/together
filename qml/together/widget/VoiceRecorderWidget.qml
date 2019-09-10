import QtQuick 1.1
import karin.together 1.0
import "../component"
import "../../js/util.js" as Util

Item{
	id: root;

	property alias recorderItem: recorder;
	signal voiceRecorded(string file);
	property int iMargins: constants._iSpacingXXXL;
	property color cColor: constants._cLightColor;

	width: constants._iSizeTooBig;
	height: width;
	objectName: "idVoiceRecorderWidget";

	Item{
		anchors.fill: parent;
		anchors.margins: root.iMargins;

		Text{
			id: durationtext;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.top: parent.top;
			height: constants._iSizeMedium;
			clip: true;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			color: root.cColor;
			font.pixelSize: constants._iFontXL;
			font.bold: recorder.state === TogetherAudioRecorder.RecordingState;
			text: recorder.state === TogetherAudioRecorder.RecordingState ? Util.FormatDuration(recorder.duration / 1000) : qsTr("Hold to record");
		}

		Item{
			id: btn;
			anchors.left: parent.left;
			anchors.right: indicator.left;
			anchors.top: durationtext.bottom;
			anchors.bottom: parent.bottom;
			anchors.rightMargin: root.iMargins;
			clip: true;
			Image{
				anchors.centerIn: parent;
				width: constants._iSizeXXXL;
				height: width;
				smooth: true;
				source: mousearea.pressed ? Qt.resolvedUrl("../../resc/voice_record_ready.png") : Qt.resolvedUrl("../../resc/voice_record_doing.png");

				MouseArea{
					id: mousearea;
					anchors.fill: parent;
					onPressed: {
						recorder.Start();
					}
					onReleased: {
						recorder.Stop();
					}
				}
			}
		}

		NoiseIndicatorWidget{
			id: indicator;
			anchors.right: parent.right;
			anchors.top: durationtext.bottom;
			anchors.bottom: parent.bottom;
			width: constants._iSizeXL;
			cColor: root.cColor;
			eUpdateMode: recorder.state === TogetherAudioRecorder.RecordingState ? 3 : 0;
		}
	}

	TogetherAudioRecorder{
		id: recorder;
		prefix: qsTr("Voice message");
		onAudioRecorded: {
			if(duration < 1000)
			controller._ShowMessage(qsTr("Voice time is too short."));
			else
			root.voiceRecorded(filePath);
		}
		onError: {
			if(error !== TogetherAudioRecorder.NoError){
				console.log("[Qml]: " + error + " -> " + errorString);
			}
		}
	}
}
