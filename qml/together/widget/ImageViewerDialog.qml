import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/main.js" as Script

HarmattanCommonDialog {
	id: root;

	objectName: "idImageViewerDialog";
	titleText: qsTr("Image viewer");

	property alias source: viewer.source;

	content: Rectangle{
		id: contentField;
		width: root.width;
		height: Math.min(root.__contentHeight, root.__maxContentHeight);
		color: constants._cDarkColor;
		ImageViewerWidget{
			id: viewer;
			anchors.fill: parent;
			cTextColor: constants._cLightColor;
		}
	}

	__drawFooterLine: true;
	tools: [
		Item{
			width: root.width;
			height: constants._iSizeLarge;
			clip: true;
			Text{
				anchors.top: parent.top;
				anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.right: open.left;
				horizontalAlignment: Text.AlignHCenter;
				verticalAlignment: Text.AlignVCenter;
				text: qsTr("Pinch image to zoom.");
				color: constants._cLightColor;
				font.bold: true;
				font.pixelSize: constants._iFontXL;
				wrapMode: Text.WordWrap;
				elide: Text.ElideRight;
				maximumLineCount: 2;
				onLinkActivated: root.__LinkClicked(link);
			}

			ToolIcon{
				id: open;
				anchors.right: parent.right;
				anchors.verticalCenter: parent.verticalCenter;
				visible: enabled;
				enabled: viewer.source != "";
				iconId: "toolbar-gallery";
				platformStyle: ToolItemStyle{
					inverted: true;
				}
				onClicked: {
					Qt.openUrlExternally(viewer.source);
				}
			}
		}
	]

	function _Load(url)
	{
		viewer.source = url;
	}

	function __LinkClicked(link)
	{
	}
}
