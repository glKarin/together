import QtQuick 1.1
import QtMultimediaKit 1.1

Item {
	id: root;
	property real currentValue: 1;
	property real minimumValue: 0;
	property real maximumValue: 1;
	property real __currentPercent: 1;
	property int iPadding: 0;
	signal move(real value, real percent);

	MouseArea {
		id: mousearea;
		anchors.top: bar.top;
		anchors.bottom: bar.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;

		onPressed: {
			root._SetPercent(mouse.y / height);
		}

		onMousePositionChanged: {
			if(pressed)
			{
				root._SetPercent(mouse.y / height);
			}
		}
	}

	Item {
		id: bar
		anchors.centerIn: parent;
		width: 8;
		height: parent.height - root.iPadding * 2;

		Rectangle {
			id: bg;
			anchors.fill: parent;
			smooth: true;
			radius: width / 2;
			border.color: constants._cDarkColor;
			border.width: 2;
			color: constants._cDarkColor;
			opacity: 0.3;
		}

		Rectangle {
			id: filler
			anchors.top: parent.top;
			anchors.horizontalCenter: parent.horizontalCenter;
			height: parent.height * root.__currentPercent;
			width: parent.width
			smooth: true;
			radius: width / 2;
			color: "blue";
			opacity: 0.6;
		}

		Rectangle {
			id: positionindicator;
			anchors.horizontalCenter: filler.horizontalCenter
			anchors.verticalCenter: filler.bottom;
			width: parent.width + 2;
			height: width;
			radius: width / 2;
			color: constants._cLightColor;
			border.color: constants._cDarkColor;
			border.width: 2;
		}
	}

	function _SetPercent(p)
	{
		__currentPercent = p;
		currentValue = (maximumValue - minimumValue) * __currentPercent + minimumValue;
		root.move(currentValue, __currentPercent);
	}

	onCurrentValueChanged: {
		__currentPercent = (currentValue - minimumValue) / (maximumValue - minimumValue)
	}
}
