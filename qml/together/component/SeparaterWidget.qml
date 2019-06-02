import QtQuick 1.1

Rectangle{
	id: root;
	property int iWidth: constants._iSpacingMicro;
	property int iMargin: constants._iSpacingLarge;
	property int eOrientation: 0;
	property Item qTarget: parent;
	color: constants._cDisableColor;
	objectName: "idSeparaterWidget";

	height: eOrientation == 1 ? (qTarget.height - iMargin * 2) : iWidth;
	width: eOrientation == 1 ? iWidth : (qTarget.width - iMargin * 2);
	anchors.horizontalCenter: eOrientation == 1 ? undefined : (qTarget ? qTarget.horizontalCenter : undefined);
	anchors.verticalCenter: eOrientation == 1 ? (qTarget ? qTarget.verticalCenter : undefined) : undefined;
}
