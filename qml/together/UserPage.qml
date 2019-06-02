import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: qsTr("User");
	objectName: "idUserPage";

	function _Init(u)
	{
		obj.user = u;
		obj._GetUserContact(u);
	}

	QtObject{
		id: obj;
		property variant user;

		function _GetUserContact()
		{
			if(typeof(user) === "string")
			{
				appobj._GetUserContact(user, userview._SetInfo);
			}
			else
			{
				userview._SetInfo(user);
			}
		}
	}

	UserViewWidget{
		id: userview;
		anchors.fill: parent;
		onPreviewClicked: {
			obj._GetUserContact();
		}

		SeparaterWidget{
			qTarget: parent;
		}
		Button{
			anchors.horizontalCenter: parent.horizontalCenter;
			text: qsTr("Send message");
			onClicked: {
				sessionmodel._AddSession(userview);
				sessionmodel._SyncCurrent(userview.uname);
				controller._OpenSessionPage(userview.uname);
			}
		}
	}
}
