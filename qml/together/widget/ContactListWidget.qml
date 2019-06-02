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
	signal refresh;
	objectName: "idContactListWidget";

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
			ContactListDelegate{
				width: ListView.view.width;
				height: constants._iSizeXXL;
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

		section.property: "pinyin_head";
		section.delegate: SectionWidget { sText: section; }
		FastScroll{
			listView: parent;
		}
	}

	ScrollDecorator{
		flickableItem: view;
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
		sessionmodel._AddSession(data);
		sessionmodel._SyncCurrent(data.uname);
		controller._OpenSessionPage(data.uname);
	}

}
