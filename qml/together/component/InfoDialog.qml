import QtQuick 1.1
import com.nokia.meego 1.1

HarmattanCommonDialog {
	id: root;

	objectName: "idInfoDialog";

	property bool bAutoOpen: true;
	property alias sTitle: layout.sTitle;
	property alias aTexts: layout.aTexts;
	property alias vNu: layout.vNu;
	property variant sBottomTitle: "";
	signal linkClicked(string link);
	signal footerClicked(string link);
	signal clicked();

	content: Item {
		id: contentField;
		width: root.width;
		height: Math.min(root.__contentHeight, root.__maxContentHeight);
		Flickable{
			id: flickable;
			anchors.fill: parent;
			clip: true;
			contentWidth: width;
			contentHeight: layout.height;
			TextListWidget{
				id: layout;
				width: parent.width;
				onClicked: root.__LinkClicked(undefined, 1);
				iPixelSize: constants._iFontXL;
				cTitleColor: constants._cLightColor;
				cColor: constants._cLightColor;
				onLinkClicked: root.__LinkClicked(link);
			}
		}

		ScrollDecorator{
			flickableItem: flickable;
		}

	}

	__drawFooterLine: sBottomTitle !== "";
	tools: [
		Text{
			width: root.width;
			height: constants._iSizeLarge;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			text: root.sBottomTitle;
			color: constants._cLightColor;
			font.bold: true;
			font.pixelSize: constants._iFontXXL;
			wrapMode: Text.WordWrap;
			elide: Text.ElideRight;
			maximumLineCount: 2;
			onLinkActivated: root.__LinkClicked(link, 2);
			
		}
	]

	Component.onCompleted: {
		if(bAutoOpen) open();
	}

	function __LinkClicked(link, where)
	{
		//root.accept();
		if(where == 2) root.footerClicked(link);
		else if(where == 1) root.clicked();
		else root.linkClicked(link);
	}

	function _Set(title, subtitle, content, bottom)
	{
		root.titleText = title;
		root.sTitle = subtitle;
		root.aTexts = content;
		root.sBottomTitle = bottom || "";
	}
}
