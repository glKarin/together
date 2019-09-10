import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

Item{
	id: root;

	property bool _inited: false;
	property int _index: 2;
	objectName: "idProfileItem";

	function _Init()
	{
		if(!_inited) obj._GetInfo(globals);
	}

	QtObject{
		id: obj;

		function _GetInfo(data)
		{
			root._inited = false;
			userview._SetInfo(data);
			root._inited = true;
		}
	}

	UserViewWidget{
		id: userview;
		anchors.fill: parent;
		onPreviewClicked: {
			root._Init();
		}
		SeparaterWidget{
			qTarget: parent;
		}

		Column{
			id: view;
			width: parent.width;
			clip: true;
			Repeater{
				model: [
					{
						label: qsTr("Transfer record"),
						name: "TransferRecord",
						icon: "directory-move-to",
						func: "controller._OpenTransferRecordPage();",
					},
					{
						label: qsTr("Setting"),
						name: "Setting",
						icon: "settings",
						func: "controller._OpenSettingPage();",
					},
					{
						label: qsTr("About"),
						name: "About",
						icon: "application",
						func: "controller._OpenAboutPage();",
					},
				]
				delegate: Component{
					Item{
						id: viewdelegateroot;
						width: view.width;
						height: constants._iSizeXXL;
						MouseArea{
							id: mousearea;
							anchors.fill: parent;
							onClicked: {
								eval(modelData.func);
							}
						}

						Row{
							anchors.fill: parent;
							anchors.margins: constants._iSpacingLarge;
							spacing: constants._iSpacingXL;
							Image{
								id: icon;
								anchors.verticalCenter: parent.verticalCenter;
								height: Math.min(constants._iSizeLarge, parent.height);
								width: height;
								source: Util.HandleIconSource("toolbar-" + modelData.icon, constants._bInverted);
								smooth: true;
							}
							Text{
								anchors.verticalCenter: parent.verticalCenter;
								width: parent.width - icon.width - parent.spacing * 2 - next.width;
								height: parent.height;
								text: modelData.label;
								verticalAlignment: Text.AlignVCenter;
								font.pixelSize: constants._iFontXL;
								elide: Text.ElideRight;
								color: mousearea.pressed ? constants._cHighlightColor : constants._cPrimaryColor;
								clip: true;
							}
							Image{
								id: next;
								anchors.verticalCenter: parent.verticalCenter;
								height: constants._iSizeMedium;
								width: height;
								source: Util.HandleIconSource("toolbar-next", constants._bInverted);
								smooth: true;
							}
						}
					}
				}
			}
		}

		SeparaterWidget{
			qTarget: parent;
		}

		Column{
			width: parent.width;
			clip: true;
			spacing: constants._iSpacingMedium;
			Button{
				anchors.horizontalCenter: parent.horizontalCenter;
				text: qsTr("Logout");
				onClicked: {
					globals._Login();
				}
			}
			Button{
				anchors.horizontalCenter: parent.horizontalCenter;
				text: qsTr("Check update");
				onClicked: {
					appobj._CheckUpdate(true);
				}
			}
			Button{
				anchors.horizontalCenter: parent.horizontalCenter;
				text: qsTr("Quit");
				onClicked: {
					Qt.quit();
				}
			}
		}
	}
}
