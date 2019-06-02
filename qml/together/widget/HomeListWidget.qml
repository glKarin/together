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
	property bool bHighlightCurrent: false;
	property int iItemHeight: constants._iSizeXXXL;
	signal refresh;
	objectName: "idHomeListWidget";

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
		currentIndex: sessionmodel.currentIndex;
		clip: true;
		z: 1;
		visible: count > 0;
		model: sessionmodel;
		header: Component{
			RefreshWidget{
				onRefresh: root.refresh();
			}
		}
		delegate: Component{
			HomeListDelegate{
				width: ListView.view.width;
				height: root.iItemHeight;
				color: root.bHighlightCurrent ? (ListView.isCurrentItem ? Qt[!constants._bInverted ? "darker" : "lighter"](constants._cBackgroundColor, 1.5) : constants._cBackgroundColor) : constants._cTransparent;
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
		z: 2;
	}

	function __Copy(index, data)
	{
		controller._CopyToClipboard(data.nickname, qsTr("Nickname"));
	}

	function __Open(index, data)
	{
		controller._OpenUserPage(data);
	}

	function __View(index, data)
	{
		sessionmodel._SyncCurrent(index);
		//sessionmodel._SyncCurrent(data.uname);
		controller._OpenSessionPage(data.uname);
	}

}
