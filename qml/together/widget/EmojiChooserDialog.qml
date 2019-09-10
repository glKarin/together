import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "emojichooserdialog.js" as Emojis

HarmattanCommonDialog {
	id: root;

	objectName: "idEmojiChooserDialog";
	titleText: qsTr("Emoji");

	property string emojis;
	property string emojiNames;
	signal select(string emojis);

	content: Rectangle{
		id: contentField;
		width: root.width;
		height: Math.min(root.__contentHeight, root.__maxContentHeight);
		color: constants._cDarkColor;
		EmojiViewWidget{
			anchors.fill: parent;
			iCellSpacing: constants._iSpacingTiny;
			onClicked: {
				Emojis.Push(emoji, name);
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
				anchors.top: parent.top;
				anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.right: backspace.left;
				//horizontalAlignment: Text.AlignHCenter;
				verticalAlignment: Text.AlignVCenter;
				text: root.emojiNames;
				color: constants._cLightColor;
				font.bold: true;
				font.pixelSize: constants._iFontLarge;
				wrapMode: Text.WordWrap;
				elide: Text.ElideRight;
				maximumLineCount: 2;
				onLinkActivated: root.__LinkClicked(link);
			}
			ToolIcon{
				id: backspace;
				anchors.right: ok.left;
				anchors.verticalCenter: parent.verticalCenter;
				visible: enabled;
				enabled: root.emojiNames !== "";
				iconId: "toolbar-close";
				onClicked: {
					Emojis.Pop();
				}
			}
			ToolIcon{
				id: ok;
				anchors.right: parent.right;
				anchors.verticalCenter: parent.verticalCenter;
				enabled: root.emojiNames !== "";
				iconId: "toolbar-done";
				onClicked: {
					Emojis.Update();
					root.select(root.emojis);
					root.accept();
				}
			}
		}
	]

	function __LinkClicked(link)
	{
	}
}
