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
	objectName: "idSessionWidget";

	Text{
		anchors.fill: parent;
		horizontalAlignment: Text.AlignHCenter;
		verticalAlignment: Text.AlignVCenter;
		font.bold: true;
		font.pixelSize: constants._iFontSuper;
		elide: Text.ElideRight;
		clip: true;
		color: constants._cDisableColor;
		text: qsTr("No message");
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
		onCountChanged: {
			positionViewAtEnd();
		}
		delegate: Component{
			SessionDelegate{
				width: ListView.view.width;
				onClicked: {
					__View(index, data);
				}
				onDoubleClicked: {
					__Include(index, data);
				}
				onAvatarClicked: {
					__Open(index, data);
				}
				onPressAndHold: {
					__Copy(index, data);
				}
				onLinkClicked: {
					controller._OpenUrl(link);
				}
			}
		}

		section.property: "ts_str";
		section.delegate: SessionSectionWidget { sText: section; }
		FastScroll{
			listView: parent;
		}
	}

	ScrollDecorator{
		flickableItem: view;
	}

	function __Copy(index, data)
	{
		controller._CopyToClipboard(data.content, qsTr("Content"));
	}

	function __Open(index, data)
	{
		controller._OpenUserPage(data.from);
	}

	function __View(index, data)
	{
	}

	function __Include(index, data)
	{
	}

}
