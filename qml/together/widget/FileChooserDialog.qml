import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

HarmattanCommonDialog {
	id: root;

	objectName: "idFileChooserDialog";
	titleText: qsTr("File chooser");

	property string name;
	property string path;
	signal select(string path, string name);

	content: Rectangle{
		id: contentField;
		width: root.width;
		height: Math.min(root.__contentHeight, root.__maxContentHeight);
		color: constants._cDarkColor;
		TabListWidget{
			id: typeview;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			height: constants._iSizeXL;
			bTabMode: true;
			bInvertedMode: true;
			cTextColor: constants._cLightColor;
			cLineColor: constants._cLightColor;
			model: [
				{
					name: qsTr("Recent upload"),
					value: 1,
				},
				{
					name: qsTr("Recent download"),
					value: 2,
				},
				{
					name: qsTr("File system"),
					value: 0,
				},
			];
			onClicked: {
				__ChangeView(value);
			}
		}

		SeparaterWidget{
			id: line;
			anchors.top: typeview.bottom;
			anchors.topMargin: constants._iSpacingSmall;
			qTarget: typeview;
			color: constants._cLightColor;
			z: 1;
		}

		TabGroup{
			id: view;
			anchors.top: line.bottom;
			anchors.topMargin: constants._iSpacingSmall;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;

			TransferListWidget{
				id: transferview;
				anchors.fill: parent;
				bOpenExternally: false;
				cTextColor: constants._cLightColor;
				onClicked: root.__Select(path, name);
			}

			FileListWidget{
				id: fileview;
				anchors.fill: parent;
				bOpenExternally: false;
				path: settings.sLastFileSystemPath;
				bDir: false;
				cTextColor: constants._cLightColor;
				onClicked: root.__Select(path, name);
				onPathChanged: {
					settings.sLastFileSystemPath = fileview.path;
				}
			}
		}
	}

	__drawFooterLine: true;
	tools: [
		Item{
			width: root.width;
			height: constants._iSizeLarge;
			clip: true;
			Text{
				width: root.width;
				height: constants._iSizeLarge;
				horizontalAlignment: Text.AlignHCenter;
				verticalAlignment: Text.AlignVCenter;
				text: qsTr("Click item to select, hold item to copy path.");
				color: constants._cLightColor;
				font.bold: true;
				font.pixelSize: constants._iFontLarge;
				wrapMode: Text.WordWrap;
				elide: Text.ElideRight;
				maximumLineCount: 2;
				onLinkActivated: root.__LinkClicked(link);
			}
		}
	]

	function __LinkClicked(link)
	{
	}

	function __ChangeView(index)
	{
		if(index == 1)
		{
			view.currentTab = transferview;
			transferview.mode = 2;
		}
		else if(index == 2)
		{
			view.currentTab = transferview;
			transferview.mode = 1;
		}
		else
		{
			view.currentTab = fileview;
		}
	}

	function __Select(path, name)
	{
		root.path = path;
		root.name = name;
		root.select(root.path, root.name);
		root.accept();
	}

	Component.onCompleted: {
		__ChangeView(1);
	}
}
