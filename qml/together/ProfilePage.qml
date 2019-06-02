import QtQuick 1.1
import com.nokia.meego 1.1
import "component"

BasePage {
	id: root;

	sTitle: qsTr("Profile");
	objectName: "idProfilePage";

	function _Init()
	{
		root.bBusy = true;
		profile._Init();
		root.bBusy = false;
	}

	ProfileItem{
		id: profile;
		anchors.fill: parent;
	}
}
