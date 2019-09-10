import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

Item{
	id: root;
	signal clicked(int index, variant data);
	signal doubleClicked(int index, variant data);
	signal longPressed(int index, variant data);
	signal iconClicked(int index, variant data);
	objectName: "idTransferListDelegate";
	property alias iconId: icon.iconId;
	property color cTextColor: constants._cPrimaryColor;

	MouseArea{
		anchors.fill: parent;
		onClicked: {
			root.clicked(index, model);
		}
		onPressAndHold: {
			root.longPressed(index, model);
		}
		onDoubleClicked: {
			root.doubleClicked(index, model);
		}
	}

	Column{
		id: info;
		anchors.fill: parent;
		anchors.leftMargin: constants._iSpacingLarge;
		anchors.rightMargin: constants._iSpacingLarge;
		anchors.topMargin: constants._iSpacingMedium;
		anchors.bottomMargin: constants._iSpacingLarge;
		Text{
			width: parent.width;
			height: parent.height - ts.height;
			text: model.name;
			font.pixelSize: constants._iFontXL;
			elide: Text.ElideMiddle;
			color: model.path ? root.cTextColor : constants._cErrorColor;
			verticalAlignment: Text.AlignVCenter;
		}
		Row{
			id: ts;
			width: parent.width;
			height: constants._iSizeSmall;
			clip: true;
			Text{
				width: parent.width / 2;
				height: parent.height;
				text: Util.FormatFileSize(model.size);
				font.pixelSize: constants._iFontMedium;
				elide: Text.ElideRight;
				color: model.path ? root.cTextColor : constants._cErrorColor;
				verticalAlignment: Text.AlignVCenter;
				horizontalAlignment: Text.AlignRight;
			}
			Text{
				width: parent.width / 2;
				height: parent.height;
				text: Util.FormatTimestamp(model.updated_time / 1000);
				font.pixelSize: constants._iFontMedium;
				elide: Text.ElideRight;
				color: model.path ? root.cTextColor : constants._cErrorColor;
				verticalAlignment: Text.AlignVCenter;
				horizontalAlignment: Text.AlignRight;
			}
		}
	}

	ToolIcon{
		id: icon;
		anchors.right: parent.right;
		anchors.verticalCenter: parent.verticalCenter;
		z: 1;
		opacity: 0.8;
		enabled: iconId != "";
		visible: enabled;
		onClicked: {
			root.iconClicked(index, model);
		}
	}

	SeparaterWidget{
		anchors.bottom: parent.bottom;
		anchors.bottomMargin: constants._iSpacingMicro;
		qTarget: info;
		z: 1;
	}
}
