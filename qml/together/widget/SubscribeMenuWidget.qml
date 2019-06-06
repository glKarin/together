import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

MenuWidget{
	id: root;
	objectName: "idSubscribeMenuWidget";
	signal viewitem(variant data);

	header: Header{
		id: header;
		iTextSize: constants._iFontXXXL;
		height: constants._iSizeXL;
		sText: qsTr("Subscribe");
		z: 1;
	}

	SubscribeListWidget{
		id: view;
		anchors.fill: parent;
		iItemHeight: constants._iSizeXXL;
		model: subscribemodel;
		onViewitem: {
			root.viewitem(data);
		}
	}
}
