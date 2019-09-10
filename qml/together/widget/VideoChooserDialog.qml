import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"

HarmattanCommonDialog {
	id: root;

	objectName: "idVideoChooserDialog";
	titleText: qsTr("Video chooser");

	property string name;
	property string path;
	signal select(string path, string name);

	content: Rectangle{
		id: contentField;
		width: root.width;
		height: Math.min(root.__contentHeight, root.__maxContentHeight);
		color: constants._cDarkColor;
		VideoChooserWidget{
			id: viewer;
			anchors.fill: parent;
			iCellSpacing: constants._iSpacingMedium;
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
}
