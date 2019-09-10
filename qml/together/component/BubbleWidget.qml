import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;
	property int iDuration: 250;
	property color cBubbleColor: eMode == 0 ? constants._cThemeColor :  constants._cClearColor;
	property color cContentColor: constants._cPrimaryColor;
	property int eMode: 0; // 0 sender, right arrow, 1 reciver, left arrow
	property alias sContent: content.text;
	property int iArrowX: __arrowWidth / 2;
	property int iContentMargin: constants._iSpacingMedium;
	property int iMinHeight: 0;
	property int iMaxWidth: 0;
	property bool bInteractive: true;

	// 0 - ready
	// 1 - loading
	// 2 - error
	// -1 - deleted

	signal linkClicked(string link);
	signal clicked(string text);
	signal doubleClicked(string text);
	signal pressAndHold(string text);

	property color __contentPressedColor: Qt[!constants._bInverted ? "lighter" : "darker"](cContentColor, 1.5);
	property color __bubblePressedColor: Qt[!constants._bInverted ? "darker" : "lighter"](cBubbleColor, 1.5);
	property color __bgColor: mousearea.pressed ? __bubblePressedColor : cBubbleColor;
	property color __contentColor: mousearea.pressed ? __contentPressedColor : cContentColor;
	property int __arrowWidth: 12;
	property int __radius: 18;

	objectName: "idBubbleWidget";
	height: Math.max(content.height + iContentMargin * 2, iMinHeight);
	width: iMaxWidth;
	clip: true;

	MouseArea{
		id: mousearea;
		anchors.fill: content;
		enabled: root.bInteractive;
		onClicked: {
			root.clicked(content.text);
		}
		onDoubleClicked: {
			root.doubleClicked(content.text);
		}
		onPressAndHold: {
			root.pressAndHold(content.text);
		}
	}

	Rectangle{
		id: arrow;
		anchors.top: parent.top;
		anchors.topMargin: root.iArrowX - width / 2;
		anchors.horizontalCenter: root.eMode == 0 ? baselayer.right : baselayer.left;
		width: root.__arrowWidth;
		height: width;
		color: baselayer.color;
		rotation: 45;
		smooth: true;
		visible: root.bInteractive;
	}

	Rectangle{
		id: baselayer;
		anchors.fill: parent;
		anchors.leftMargin: root.eMode == 0 ? 0 : arrow.width;
		anchors.rightMargin: root.eMode == 0 ? arrow.width : 0;
		z: 1;
		color: root.__bgColor;
		radius: root.__radius;
		smooth: true;
		visible: root.bInteractive;
		Rectangle{
			id: toplayer;
			anchors.fill: parent;
			anchors.bottomMargin: baselayer.radius;
			color: baselayer.color;
		}
		Rectangle{
			id: bottomlayer;
			anchors.fill: parent;
			anchors.leftMargin: root.eMode == 0 ? baselayer.radius : 0;
			anchors.rightMargin: root.eMode == 0 ? 0 : baselayer.radius;
			color: baselayer.color;
		}
	}

	Text{
		id: content;
		anchors.top: parent.top;
		anchors.topMargin: root.iContentMargin;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.leftMargin: root.eMode == 0 ? baselayer.radius : arrow.width + root.iContentMargin;
		anchors.rightMargin: root.eMode == 0 ? arrow.width + root.iContentMargin : baselayer.radius;
		verticalAlignment: Text.AlignVCenter;
		z: 2;
		wrapMode: Text.WrapAnywhere;
		font.pixelSize:constants._iFontXL;
		color: root.__contentColor;
		textFormat: Text.RichText;
		onLinkActivated: {
			if(root.bInteractive)
			root.linkClicked(link);
		}
	}

}
