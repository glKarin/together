import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

Item{
	id: root;
	signal clicked(int index, variant data);
	signal doubleClicked(int index, variant data);
	signal longPressed(int index, variant data);
	property color cTextColor: constants._cPrimaryColor;
	objectName: "idFileListDelegate";

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
		anchors.bottomMargin: constants._iSpacingMedium;
		Text{
			width: parent.width;
			height: parent.height - ts.height;
			text: model.name;
			font.pixelSize: constants._iFontXL;
			elide: Text.ElideMiddle;
			color: root.cTextColor;
			verticalAlignment: Text.AlignVCenter;
		}
		Row{
			id: ts;
			visible: model.name !== "../";
			width: parent.width;
			height: constants._iSizeSmall;
			clip: true;
			Text{
				width: parent.width / 3 * 2;
				height: parent.height;
				text: model.owner + " : " + model.group + "     " + Util.FormatFileMode(model.mode);
				font.pixelSize: constants._iFontMedium;
				elide: Text.ElideRight;
				color: root.cTextColor;
				verticalAlignment: Text.AlignVCenter;
				horizontalAlignment: Text.AlignRight;
			}
			Text{
				width: parent.width / 3;
				height: parent.height;
				text: Util.FormatFileSize(model.size);
				font.pixelSize: constants._iFontMedium;
				elide: Text.ElideRight;
				color: root.cTextColor;
				verticalAlignment: Text.AlignVCenter;
				horizontalAlignment: Text.AlignRight;
			}
		}
	}
}
