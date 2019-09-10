import QtQuick 1.1

Item{
	id: root;
	property alias source: icon.source;
	property alias text: label.text;
	property int iMargins: constants._iSpacingMedium;
	property bool checked: false;
	property bool bTriggered: true;
	property bool pressed: mousearea.pressed;
	property alias color: label.color;
	signal clicked();

	width: constants._iSizeXXL
	height: constants._iSizeXXL + constants._iSizeMedium;
	objectName: "idImageButtonWidget";

	Column{
		anchors.fill: parent;
		anchors.margins: root.iMargins;
		spacing: constants._iSpacingMedium;
		clip: true;
		Image{
			id: icon;
			anchors.horizontalCenter: parent.horizontalCenter;
			width: parent.width;
			height: width;
			smooth: true;
			cache: false;
		}
		Text{
			id: label;
			anchors.horizontalCenter: parent.horizontalCenter;
			width: parent.width;
			height: parent.height - icon.height - parent.spacing;
			clip: true;
			elide: Text.ElideRight;
			font.pixelSize: constants._iFontLarge;
			verticalAlignment: Text.AlignVCenter;
			horizontalAlignment: Text.AlignHCenter;
			color: constants._cPrimaryColor;
		}
	}

	MouseArea{
		id: mousearea;
		anchors.fill: parent;
		onClicked: {
			root.clicked();
		}
		onPressed: {
			if(root.bTriggered)
			root.checked = true;
			else
			root.checked = !root.checked;
		}
		onReleased: {
			if(root.bTriggered)
			root.checked = false;
		}
	}
}
