// form ToolIcon of QtComponents by Nokia
import QtQuick 1.1
import "../../js/util.js" as Util

Rectangle{
	id: root
	objectName: "idIconWidget";
	property url iconSource;
	property string platformIconId;
	property bool inverted: constants._bInverted;
	property alias iconId: root.platformIconId;
	property bool enabled: true;
	/*
	property int iDragMinimumY;
	property int iDragMaximumY;
	property int iDragMinimumX;
	property int iDragMaximumX;
	*/
	property int eDragAxis: Drag.XandYAxis;
	property bool bDragable: settings.bTouchIconDrag;
	signal clicked;

	radius: Math.min(width, height) / 2;
	color: constants._cGlobalColor;
	width: constants._iSizeXL;
	height: width;
	clip: true;

	Image{
		anchors.centerIn: parent;
		source: iconSource != "" ? iconSource : Util.HandleIconSource(iconId, inverted);
	}

	Rectangle{
		id: mask;
		anchors.fill: parent;
		visible: mouseArea.pressed || !root.enabled;
		opacity: root.enabled ? 0.6 : 0.8;
		color: constants._cPrimaryColor;
		radius: root.radius;
	}

	MouseArea{
		id: mouseArea;
		anchors.fill: parent;
		drag.target: root.bDragable ? root : undefined;
		drag.axis: root.eDragAxis;
		/*
		drag.minimumY: root.iDragMinimumY;
		drag.maximumY: root.iDragMaximumY;
		drag.minimumX: root.iDragMinimumX;
		drag.maximumX: root.iDragMaximumX;
		*/
	}

	Component.onCompleted: {
		mouseArea.clicked.connect(function(){
			if(root.enabled) root.clicked();
		});
	}
}
