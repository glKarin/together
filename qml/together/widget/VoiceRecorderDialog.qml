import QtQuick 1.1
import "../component"

LayerWidget{
	id: root;

	signal recorded(string path, string name);

	objectName: "idVoiceRecorderDialog";
	anchors.fill: parent;
	cBackgroundColor: constants._cTransparent;
	bAutoOpen: true;
	bAutoDestroy: true;
	eContentSizePolicy: 1;
	contentItem.opacity: 0.8;
	contentItem.radius: constants._iSpacingXXXL;

	VoiceRecorderWidget{
		id: recorder;
		onVoiceRecorded: {
			root.recorded(file, _UT.GetFileInfo(file, "FILE_NAME"));
			root._Close();
		}
	}
}
