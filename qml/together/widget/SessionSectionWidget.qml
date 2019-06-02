import QtQuick 1.1

Item {
	id: root;

	property alias sText: label.text;
	property alias cTextColot: label.color;
	property alias cColor: line.color;
	property int iMargins: constants._iSpacingMedium;

	objectName: "idSessionSectionWidget";
	width: parent.width;
	height: constants._iSizeLarge;
	clip: true;

	Rectangle{
		id: line;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.topMargin: root.iMargins;
		anchors.bottomMargin: root.iMargins;
		anchors.horizontalCenter: parent.horizontalCenter;
		width: label.paintedWidth + constants._iSpacingMedium * 2;
		z: 1;
		color: constants._cBackgroundColor;
		smooth: true;
		radius: 8;
		Text{
			id: label;
			height: parent.height;
			width: parent.width;
			verticalAlignment: Text.AlignVCenter;
			horizontalAlignment: Text.AlignHCenter;
			font.pixelSize: constants._iFontXL;
			color: constants._cClearColor;
		}
	}
}
