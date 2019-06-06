import com.nokia.meego 1.1

ContextMenu{
	id: root;
	property int currentTab: 0;
	objectName: "idHomeTabMenuWidget";
	signal showTab(int index);

	MenuLayout {
		MenuItem{
			property int index: 3;
			text: qsTr("Home");
			enabled: root.currentTab != index;
			onClicked: {
				root.showTab(index);
			}
		}
		MenuItem{
			property int index: 0;
			text: qsTr("Subscribe");
			enabled: root.currentTab != index;
			onClicked: {
				root.showTab(index);
			}
		}
		MenuItem{
			property int index: 1;
			text: qsTr("Contacts");
			enabled: root.currentTab != index;
			onClicked: {
				root.showTab(index);
			}
		}
		MenuItem{
			property int index: 2;
			text: qsTr("Profile");
			enabled: root.currentTab != index;
			onClicked: {
				root.showTab(index);
			}
		}
		MenuItem{
			text: qsTr("Refresh");
			onClicked: {
				obj._GetInitData(true);
			}
		}
		MenuItem{
			text: qsTr("Relogin");
			onClicked: {
				globals._Login();
			}
		}
		MenuItem{
			text: qsTr("Quit");
			onClicked: {
				Qt.quit();
			}
		}
	}
}
