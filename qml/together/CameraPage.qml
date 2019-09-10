import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage{
	id: root;

	bPopI: true;
	sTitle: qsTr("Camera");
	objectName: "idCameraPage";
	//orientationLock: PageOrientation.LockPortrait;
	signal captured(string previewImage);

	function _Init(nw)
	{
	}

	Rectangle{
		id: bg;
		anchors.centerIn: parent;
		width: app.inPortrait ? parent.height : parent.width;
		height: app.inPortrait ? parent.width : parent.height;
		color: constants._cDarkColor;
		rotation: app.inPortrait ? 90 : 0;
		CameraWidget{
			id: cam;
			anchors.fill: parent;
			eOrientation: app.inPortrait ? 1 : 0;
			onCaptured: {
				root.captured(previewImage);
				if(pageStack.depth > 1)
				pageStack.pop(undefined, true);
			}
		}
	}

	Component.onCompleted: {
		root.bFull = app.showStatusBar;
		app.showStatusBar = false;
	}
	Component.onDestruction: {
		app.showStatusBar = root.bFull;
	}
}
