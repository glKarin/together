import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

MenuWidget{
	id: root;
	objectName: "idContactMenuWidget";

	header: Header{
		id: header;
		iTextSize: constants._iFontBig;
		iTextMargin: icon.width;
		height: constants._iSizeXXXL;
		sText: globals.nickname;
		z: 1;
		onClicked: {
			controller._OpenProfilePage();
		}
		Image{
			id: icon;
			cache: false;
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
			z: 1;
			width: constants._iSizeXL;
			height: width;
			smooth: true;
			source: globals.avatar;
		}
	}

	HomeListWidget{
		id: view;
		anchors.fill: parent;
		iItemHeight: constants._iSizeXXL;
		model: sessionmodel;
		bHighlightCurrent: true;
	}

}
