import QtQuick 1.1

Rectangle{
	id: root;
	objectName: "idLabelWidget";
	property string sText: "";
	property alias iPixelSize: title.font.pixelSize;

	width: childrenRect.width;
	height: constants._iSizeSmall;
	color: constants._cThemeColor;
	visible: title.text !== "";
	clip: true;
	radius: 6;
	smooth: true;
	Text{
		id: title;
		height: parent.height;
		verticalAlignment: Text.AlignVCenter;
		horizontalAlignment: Text.AlignHCenter;
		font.bold: true;
		font.pixelSize: constants._iFontLarge;
		color: constants._cDarkColor;
		clip: true;
		text: " " + root.sText + " ";
	}
}
