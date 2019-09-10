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
		obj._GetUserContact();
	}

	QtObject{
		id: obj;
		property variant user;

		function _GetUserContact()
		{
			if(typeof(user) === "string")
			{
				var str = user.split(" ");
				appobj._GetUserContact(str[0], userview._SetInfo, str[1]);
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
			enabled: userview.uname !== "";
			onClicked: {
				if(userview.uname)
				{
					sessionmodel._AddSession(userview);
					sessionmodel._SyncCurrent(userview.uname);
					controller._OpenSessionPage(userview.uname);
				}
			}
		}
	}
}
