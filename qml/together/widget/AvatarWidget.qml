import QtQuick 1.1

Image{
	id: root;
	property alias mouseArea: mousearea;
	signal clicked();

	objectName: "idAvatarWidget";
	width: height;
	fillMode: Image.PreserveAspectCrop;
	clip: true;
	//cache: true;
	smooth: true;
	source: constants._sAvatarDefault;
	sourceSize: Qt.size(width, height);
	onStatusChanged: {
		if(status == Image.Error && root.source != constants._sAvatarDefault)
		{
			root.source = constants._sAvatarDefault;
		}
	}
	MouseArea{
		id: mousearea;
		anchors.fill: parent;
		onClicked: {
			root.clicked();
		}
	}
}
