import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

Item{
	id: root;
	signal clicked(int index, variant data);
	signal imageClicked(int index, variant data);
	signal longPressed(int index, variant data);
	objectName: "idContactListDelegate";

	MouseArea{
		anchors.fill: parent;
		onClicked: {
			root.clicked(index, model);
		}
		onPressAndHold: {
			root.longPressed(index, model);
		}
	}

	Image{
		id: avatar;
		anchors.left: parent.left;
		anchors.leftMargin: constants._iSpacingLarge;
		anchors.verticalCenter: parent.verticalCenter;
		height: parent.height - constants._iSpacingLarge * 2;
		width: height;
		fillMode: Image.PreserveAspectCrop;
		smooth: true;
		clip: true
		source: model.avatar;
		//cache: false;
		sourceSize: Qt.size(width, height);
		MouseArea{
			anchors.fill: parent;
			onClicked: {
				root.imageClicked(index, model);
			}
		}
	}

	Text{
		id: info;
		anchors.left: avatar.right;
		anchors.leftMargin: constants._iSpacingMedium;
		anchors.right: parent.right;
		anchors.rightMargin: constants._iSpacingLarge;
		anchors.verticalCenter: parent.verticalCenter;
		height: avatar.height;
		text: globals._GetUserShownName(model);
		font.pixelSize: constants._iFontXL;
		elide: Text.ElideRight;
		color: constants._cPrimaryColor;
		verticalAlignment: Text.AlignVCenter;
	}

	SeparaterWidget{
		anchors.bottom: parent.bottom;
		anchors.bottomMargin: constants._iSpacingMicro;
		qTarget: info;
		z: 1;
	}

}
