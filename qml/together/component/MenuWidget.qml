import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	objectName: "idMenuWidget";
	property int iMenuWidth: width - constants._iSizeXXXL;
	property int iAnimInterval: 320;
	property alias tools: toolbarlayout.children;
	property alias header: headers.children;
	default property alias content: contents.children;

	z: constants._iMenuZ;
	clip: true;
	visible: menu.x !== -iMenuWidth;

	RectWidget{
		id: mask;
		anchors.fill: parent;
		visible: opacity !== 0;
		color: constants._cDarkColor;
		state: menu.state;
		iStart: 0;
		iTarget: 0.6;
		sProperty: "opacity";
		iDuration: root.iAnimInterval;
		MouseArea{
			anchors.fill: parent;
			onClicked: {
				root._Toggle(false);
			}
		}
	}

	RectWidget{
		id: menu;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		width: root.iMenuWidth;
		z: 1;
		color: constants._cBackgroundColor;
		state: constants._sHideState;
		iStart: -root.iMenuWidth;
		iTarget: 0;
		sProperty: "x";
		iDuration: root.iAnimInterval;

		Item{
			id: headers;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			height: childrenRect.height;
			z: 1;
			clip: true;
		}

		Item{
			id: contents;
			anchors.top: headers.bottom;
			anchors.bottom: tb.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.topMargin: constants._iSpacingMedium;
			anchors.bottomMargin: constants._iSpacingMedium;
			clip: true;
		}

		Item{
			id: tb;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			height: toolbarlayout.children.length > 0 ? constants._iSizeXL : 0;
			visible: toolbarlayout.children.length > 0;
			clip: true;
			ToolBarLayout{
				id: toolbarlayout;
				anchors.fill: parent;
			}
			SeparaterWidget{
				anchors.top: parent.top;
				qTarget: tb;
				z: 1;
			}
		}
	}

	function _Toggle(on)
	{
		if(on === undefined)
		{
			if(menu.state === constants._sHideState) menu.state = constants._sShowState;
			else if(menu.state === constants._sShowState) menu.state = constants._sHideState;
		}
		else
		{
			menu.state = on ? constants._sShowState : constants._sHideState;
		}
	}
}
