import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;
	objectName: "idFooterWidget";
	property alias bEnabled: more.enabled;
	property string sText: qsTr("More");
	property string sTextNoMore: qsTr("No more");
	signal clicked;

	width: GridView.view ? GridView.view.width : ListView.view.width;
	height: childrenRect.height;

	Button{
		id: more;
		anchors.horizontalCenter: parent.horizontalCenter;
		text: enabled ? root.sText : root.sTextNoMore;
		onClicked: root.clicked();
	}
}
