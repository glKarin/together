import QtQuick 1.1
import com.nokia.meego 1.1
import karin.together 1.0
import "../component"
import "../../js/main.js" as Script
import "../../js/util.js" as Util

Item{
	id: root;
	property alias mode: transfermodel.mode;
	property alias count: view.count;
	property alias model: transfermodel;
	property int showIcon: 0;
	property bool bOpenExternally: true;
	property color cTextColor: constants._cPrimaryColor;
	signal clicked(string path, string name);

	objectName: "idTransferListWidget";

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
			onClicked: transfermodel.Restore();
		}
	}

	ListView{
		id: view;
		anchors.fill: parent;
		clip: true;
		z: 1;
		visible: count > 0;
		model: TogetherTransferRecord{
			id: transfermodel;
			onModeChanged: {
				view.positionViewAtBeginning();
			}
		}
		header: Component{
			RefreshWidget{
				onRefresh: transfermodel.Restore();
			}
		}
		delegate: Component{
			TransferListDelegate{
				id: delegateroot;
				width: ListView.view.width;
				height: constants._iSizeXXL;
				iconId: root.showIcon === 3 ? "toolbar-delete" : (root.showIcon === 2 ? "toolbar-close" : (root.showIcon === 1 ? "toolbar-search" : ""));
				cTextColor: root.cTextColor;
				onClicked: {
					__View(index, data);
				}
				onDoubleClicked: {
					__Open(index, data);
				}
				onLongPressed: {
					__Copy(index, data);
				}
				onIconClicked: {
					if(root.showIcon === 2)
					{
						delegateroot.iconId = "";
						transfermodel.Delete(data.id);
					}
					else if(root.showIcon === 3)
					{
						delegateroot.iconId = "";
						transfermodel.Delete(data.id, true);
					}
					else if(showIcon === 1)
					{
						__Open(index, model);
					}
				}
			}
		}

		section.property: "date";
		FastScroll{
			visible: root.showIcon === 0;
			listView: parent;
		}
	}

	ScrollDecorator{
		flickableItem: view;
	}

	function __Copy(index, data)
	{
		controller._CopyToClipboard(data.path, qsTr("File path"));
	}

	function __Open(index, data)
	{
		controller._OpenFile(data.path, bOpenExternally);
	}

	function __View(index, data)
	{
		root.clicked(data.path, data.name);
	}

	function _Update()
	{
		transfermodel.Restore();
	}

	function _Clear(file)
	{
		transfermodel.Clean(1 | (file ? (4 | 2) : 2));
	}
}
