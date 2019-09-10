import QtQuick 1.1
import "../component"
import "../../js/main.js" as Script

Column{
	id: root;
	property alias model: repeater.model;
	property color cTextColor: constants._cPrimaryColor;
	property string sChatRoomId;
	signal clicked(string uname, string nickname, string chatroomid);

	objectName: "idGroupMemberWidget";
	spacing: constants._iSpacingLarge;

	SectionWidget{
		anchors.horizontalCenter: parent.horizontalCenter;
		width: parent.width;
		sText: qsTr("Group member") + ": " + repeater.model.count;
		eTextAlign: constants._sAlignCenter;
		cTextColor: root.cTextColor;
	}

	Grid{
		id: view;
		property int __cellWidth: constants._iSizeXXL;
		property int __cellHeight: constants._iSizeXXXL;
		anchors.horizontalCenter: parent.horizontalCenter;
		spacing: constants._iSpacingLarge;
		columns: Math.floor(root.width / (__cellWidth + spacing));
		Repeater{
			id: repeater;
			model: ListModel{}
			delegate: Component{
				Item{
					id: delegateroot;
					width: view.__cellWidth;
					height: view.__cellHeight;
					clip: true;
					AvatarWidget{
						id: avatar;
						anchors.top: parent.top;
						anchors.left: parent.left;
						anchors.right: parent.right;
						height: width;
						source: Script.GetAvatarUrl(model.uname, root.sChatRoomId);
						cache: false;
					}
					Text{
						anchors.top: avatar.bottom;
						anchors.bottom: parent.bottom;
						anchors.left: parent.left;
						anchors.right: parent.right;
						horizontalAlignment: Text.AlignHCenter;
						verticalAlignment: Text.AlignVCenter;
						elide: Text.ElideRight;
						font.pixelSize: constants._iFontMedium;
						text: model.nickname;
						color: root.cTextColor;
					}
					MouseArea{
						anchors.fill: parent;
						onClicked: {
							root.clicked(model.uname, model.nickname, root.sChatRoomId);
						}
					}
				}
			}
		}
	}
}
