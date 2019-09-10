import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Rectangle{
	id: root;
	property alias model: view.model;
	property alias count: view.count;
	objectName: "idToolbarWidget";
	height: 48;
	color: constants._cBackgroundColor;
	//visible: count > 0;

	ListView{
		id: view;
		anchors.fill: parent;
		clip: true;
		z: 1;
		interactive: contentWidth > width;
		orientation: ListView.Horizontal;
		spacing: constants._iSpacingMedium;
		model: []
		delegate: Component{
			ToolIcon{
				width: height;
				height: ListView.view.height;
				iconId: modelData.icon;
				enabled: modelData.enabled !== undefined ? modelData.enabled : true;
				onClicked: {
					eval(modelData.script);
				}
			}
		}
	}

	/*
	ScrollDecorator{
		flickableItem: view;
	}
	*/
}
