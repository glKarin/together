import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/main.js" as Script
import "../../js/util.js" as Util

Item{
	id: root;
	property alias model: view.model;
	property alias count: view.count;
	property alias interactive: view.interactive;
	property int iItemHeight: constants._iSizeXXXL;
	signal refresh;
	signal viewitem(variant data);
	objectName: "idSubscribeListWidget";

	Text{
		anchors.fill: parent;
		horizontalAlignment: Text.AlignHCenter;
		verticalAlignment: Text.AlignVCenter;
		font.bold: true;
		font.pixelSize: constants._iFontSuper;
		elide: Text.ElideRight;
		clip: true;
		color: constants._cDisableColor;
		text: qsTr("No content");
		visible: view.count === 0;
		MouseArea{
			anchors.centerIn: parent;
			width: parent.paintedWidth;
			height: parent.paintedHeight;
			onClicked: root.refresh();
		}
	}

	ListView{
		id: view;
		anchors.fill: parent;
		clip: true;
		z: 1;
		visible: count > 0;
		model: ListModel{}
		header: Component{
			RefreshWidget{
				onRefresh: root.refresh();
			}
		}
		delegate: Component{
			SubscribeListDelegate{
				width: ListView.view.width;
				iSubItemHeight: root.iItemHeight;
				onClicked: {
					__View(index, data);
				}
				onImageClicked: {
					__Open(index, data);
				}
				onLongPressed: {
					__Copy(index, data);
				}
			}
		}
	}

	ScrollDecorator{
		flickableItem: view;
	}

	function __Copy(index, data)
	{
		controller._CopyToClipboard(data.url, qsTr("Article URL"));
	}

	function __Open(index, data)
	{
		root.viewitem(data);
	}

	function __View(index, data)
	{
		__Open(index, data);
	}

}
