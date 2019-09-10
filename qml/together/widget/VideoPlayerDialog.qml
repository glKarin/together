import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/main.js" as Script

HarmattanCommonDialog {
	id: root;

	objectName: "idVideoPlayerDialog";
	titleText: qsTr("Video player");

	property alias source: player.source;

	content: Rectangle{
		id: contentField;
		width: root.width;
		height: Math.min(root.__contentHeight, root.__maxContentHeight);
		color: constants._cDarkColor;
		VideoPlayerWidget{
			id: player;
			anchors.fill: parent;
			bLoop: true;
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
				enabled: player.source != "";
				iconId: "toolbar-gallery";
				platformStyle: ToolItemStyle{
					inverted: true;
				}
				onClicked: {
					Qt.openUrlExternally(player.source);
				}
			}
		}
	]

	function _Load(url)
	{
		player.source = url;
	}

	function __LinkClicked(link)
	{
	}
}

