import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	property alias model: view.model;
	property alias count: view.count;
	property color cLineColor: constants._cSecondaryColor;
	property color cTextColor: constants._cPrimaryColor;
	property bool bInteractive: true;
	property bool bTabMode: false;
	property bool bInvertedMode: !constants._bInverted;
	property bool bFixedWidth: true;
	property int iTopMargin: 0;
	property int iBottomMargin: 0;
	property alias currentIndex: view.currentIndex;
	signal clicked(string name, string value, int index);
	objectName: "idTabListWidget";

	function _LoadModel(jsarr, limit)
	{
		view.model.clear();
		for(var i in jsarr)
		{
			if(limit && i >= limit) break;
			var e = jsarr[i];
			Util.ModelPush(view.model, e);
		}
	}

	ListView{
		id: view;
		anchors.fill: parent;
		anchors.topMargin: root.iTopMargin;
		anchors.bottomMargin: root.iBottomMargin;
		clip: true;
		orientation: ListView.Horizontal;
		interactive: !root.bTabMode;
		model: ListModel{}
		delegate: Component{
			Item{
				id: delegateroot;
				property int iLineWidth: constants._iSpacingMedium;
				width: root.bTabMode ? (ListView.view.count > 0 ? ListView.view.width / ListView.view.count : ListView.view.width) : constants._iSizeXXXL;
				height: ListView.view.height;
				clip: true;
				MouseArea{
					anchors.fill: parent;
					onClicked: {
						if(root.bInteractive)
						{
							view.currentIndex = index;
							root.clicked(model.name, model.value, index);
						}
					}
				}
				Rectangle{
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.topMargin: border.width / 2;
					anchors.leftMargin: border.width / 2;
					anchors.rightMargin: border.width / 2;
					height: parent.height + border.width;
					border.width: iLineWidth;
					visible: !root.bInvertedMode && delegateroot.ListView.isCurrentItem;
					border.color: root.cLineColor;
					radius: border.width;
					smooth: true;
					color: constants._cTransparent;
				}
				Text{
					anchors.fill: parent;
					anchors.margins: iLineWidth;
					horizontalAlignment: Text.AlignHCenter;
					verticalAlignment: Text.AlignVCenter;
					elide: Text.ElideLeft;
					color: root.bInvertedMode ? constants._cPrimaryColor : root.cTextColor;
					font.pixelSize: constants._iFontXL;
					font.bold: delegateroot.ListView.isCurrentItem;
					text: model.name;
				}
				Rectangle{
					id: line;
					anchors.bottom: parent.bottom;
					anchors.left: parent.left;
					anchors.right: parent.right;
					height: iLineWidth;
					color: root.bInvertedMode ? constants._cPrimaryColor : root.cLineColor;
					visible: (!root.bInvertedMode && !delegateroot.ListView.isCurrentItem) || (root.bInvertedMode && delegateroot.ListView.isCurrentItem);
				}
			}
		}
	}
}
