import QtQuick 1.1
import com.nokia.meego 1.1
import karin.together 1.0
import "../component"
import "../../js/main.js" as Script
import "../../js/util.js" as Util

Item{
	id: root;
	property alias count: view.count;
	property alias model: filemodel;
	property alias path: filemodel.path;
	property bool bDir: true;
	property bool bOpenExternally: true;
	property color cTextColor: constants._cPrimaryColor;
	signal clicked(string path, string name);

	objectName: "idFileListWidget";

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
			onClicked: filemodel.Restore();
		}
	}

	ListView{
		id: view;
		anchors.fill: parent;
		clip: true;
		z: 1;
		visible: count > 0;
		model: TogetherFileModel{
			id: filemodel;
			onPathChanged: {
				view.positionViewAtBeginning();
			}
		}
		header: Component{
			RefreshWidget{
				onRefresh: filemodel.Restore();
			}
		}
		delegate: Component{
			FileListDelegate{
				id: delegateroot;
				width: ListView.view.width;
				height: constants._iSizeXXL;
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
			}
		}

		/*
		section.property: "name";
		section.criteria: ViewSection.FirstCharacter;
		*/
		section.property: "alphabet";
		FastScroll{
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
		if(data.suffix === "/")
		filemodel.path = data.path;
		else
		controller._OpenFile(data.path, bOpenExternally);
	}

	function __View(index, data)
	{
		if(data.suffix !== "/" || root.bDir)
		root.clicked(data.path, data.name);
	}

}
