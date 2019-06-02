import QtQuick 1.1

Item{
	id: root;
	property int level: 0;

	objectName: "idLVWidget";
	height: constants._iSizeMedium;
	width: lv.width + num.width;
	clip: true;

	Rectangle{
		id: lv;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		width: childrenRect.width;
		height: childrenRect.height;
		clip: true;
		color: constants._GetLevelColor(level);
		Text{
			font.bold: true;
			font.pixelSize: constants._iFontLarge;
			color: constants._cLightColor;
			clip: true;
			text: " LV";
		}
	}
	Rectangle{
		id: num;
		anchors.left: lv.right;
		anchors.bottom: parent.bottom;
		width: childrenRect.width;
		height: childrenRect.height;
		clip: true;
		color: constants._GetLevelColor(level);
		Text{
			font.bold: true;
			font.pixelSize: constants._iFontLarge + 2;
			color: constants._cLightColor;
			clip: true;
			text: "" + root.level + " ";
		}
	}
}
