import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

HarmattanCommonDialog {
	id: root;

	objectName: "idImageChooserDialog";
	titleText: __name + qsTr(" chooser");

	property bool gifOnly: false;
	property string __name: "";
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
					name: qsTr("Image"),
					value: "",
				},
				{
					name: qsTr("Gif emoji"),
					value: "*.gif",
				},
			];
			onClicked: {
				__ChangeView(name, value, index);
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

		ImageChooserWidget{
			id: viewer;
			anchors.top: line.bottom;
			anchors.topMargin: constants._iSpacingSmall;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			iCellSpacing: constants._iSpacingTiny;
			onSelect: {
				root.__Select(filePath, fileName);
			}
		}
	}

	__drawFooterLine: true;
	tools: [
		Text{
			width: root.width;
			height: constants._iSizeLarge;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			text: qsTr("Click item to select, hold item to view.");
			color: constants._cLightColor;
			font.bold: true;
			font.pixelSize: constants._iFontXL;
			wrapMode: Text.WordWrap;
			elide: Text.ElideRight;
			maximumLineCount: 2;
			onLinkActivated: root.__LinkClicked(link);
		}
	]

	function __Select(path, name)
	{
		root.path = path;
		root.name = name;
		root.select(root.path, root.name);
		root.accept();
	}

	function __LinkClicked(link)
	{
		if(link === "_Update")
		{
			viewer._Reload();
		}
		else if(link === "_Close")
		{
			root.reject();
		}
	}

	function __ChangeView(name, value, index)
	{
		root.gifOnly = index === 1;
		root.__name = name;
		viewer.sFilter = value;
	}

	Component.onCompleted: {
		var i = root.gifOnly ? 1 : 0;
		__ChangeView(Util.ModelGetValue(typeview.model, i, "name"), Util.ModelGetValue(typeview.model, i, "value"), i);
	}
}
