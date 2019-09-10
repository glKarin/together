import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

Rectangle{
	id: root;
	signal clicked(int index, variant data);
	signal imageClicked(int index, variant data);
	signal longPressed(int index, variant data);
	objectName: "idHomeListDelegate";
	color: constants._cTransparent;

	MouseArea{
		anchors.fill: parent;
		onClicked: {
			root.clicked(index, model);
		}
		onPressAndHold: {
			root.longPressed(index, model);
		}
	}

	AvatarWidget{
		id: avatar;
		anchors.left: parent.left;
		anchors.leftMargin: constants._iSpacingLarge;
		anchors.verticalCenter: parent.verticalCenter;
		height: parent.height - constants._iSpacingLarge * 2;
		width: height;
		source: model.avatar;
		onClicked: {
			root.imageClicked(index, model);
		}
	}

	Item{
		id: info;
		anchors.left: avatar.right;
		anchors.leftMargin: constants._iSpacingMedium;
		anchors.right: parent.right;
		anchors.rightMargin: constants._iSpacingLarge;
		anchors.verticalCenter: parent.verticalCenter;
		height: avatar.height;
		clip: true;
		Text{
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: content.top;
			text: globals._GetUserShownName(model);
			font.pixelSize: constants._iFontXL;
			elide: Text.ElideRight;
			color: constants._cPrimaryColor;
			verticalAlignment: Text.AlignVCenter;
			z: 1
		}
		Text{
			id: content;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			height: parent.height / 2;
			text: model.last_msg ? model.last_msg : model.signature;
			font.pixelSize: constants._iFontLarge;
			elide: Text.ElideRight;
			color: constants._cSecondaryColor;
			maximumLineCount: 2;
			wrapMode: Text.WrapAnywhere;
			//verticalAlignment: Text.AlignVCenter;
			textFormat: Text.RichText;
			clip: true;
		}
	}
	LabelWidget{
		anchors.horizontalCenter: info.right;
		anchors.top: info.top;
		width: height;
		radius: width / 2;
		z: 2;
		sText: model.unread.toString();
		visible: model.unread > 0;
		iPixelSize: constants._iFontMedium;
	}

	LabelWidget{
		anchors.right: info.right;
		anchors.bottom: info.bottom;
		z: 1;
		sText: qsTr("Unsend");
		visible: model.unsend !== "";
		iPixelSize: constants._iFontMedium;
	}

	SeparaterWidget{
		id: sep;
		anchors.bottom: parent.bottom;
		anchors.bottomMargin: constants._iSpacingMicro;
		qTarget: info;
		z: 1;
	}

}

