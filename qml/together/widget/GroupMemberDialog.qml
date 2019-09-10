import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/main.js" as Script
import "../../js/util.js" as Util

HarmattanCommonDialog {
	id: root;

	objectName: "idGroupMemberDialog";
	titleText: nickname;

	property string uname;
	property string chatroomid;
	property string nickname;
	property string avatar;

	property string memberNickname;
	property string memberUname;
	signal select(string memberUname, string chatroomid, string memberNickname);

	content: Rectangle{
		id: contentField;
		width: root.width;
		height: Math.min(root.__contentHeight, root.__maxContentHeight);
		color: constants._cDarkColor;
		Flickable{
			id: viewer;
			anchors.fill: parent;
			contentWidth: width;
			contentHeight: member.height;
			clip: true;
			GroupMemberWidget{
				id: member;
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width;
				sChatRoomId: root.chatroomid;
				cTextColor: constants._cLightColor;
				onClicked: {
					root.__Select(uname, nickname);
				}
			}
		}
		ScrollDecorator{
			flickableItem: viewer;
		}
	}

	__drawFooterLine: true;
	tools: [
		Text{
			width: root.width;
			height: constants._iSizeLarge;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			text: qsTr("Click item to select.");
			color: constants._cLightColor;
			font.bold: true;
			font.pixelSize: constants._iFontXL;
			wrapMode: Text.WordWrap;
			elide: Text.ElideRight;
			maximumLineCount: 2;
			onLinkActivated: root.__LinkClicked(link);
		}
	]

	function __Select(uname, nickname)
	{
		root.memberUname = uname;
		root.memberNickname = nickname;
		root.select(root.memberUname, root.chatroomid, root.memberNickname);
		root.accept();
	}

	function __LinkClicked(link)
	{
	}

	function _Init(data)
	{
		if(typeof(data) === "string")
		{
			var str = data.split(" ");
			appobj._GetUserContact(str[0], __SetGroupInfo, str[1]);
		}
		else
		{
			__SetGroupInfo(data);
		}
	}

	function __SetGroupInfo(data)
	{
		var Keys = [
			"uname", "nickname", "avatar", "chatroomid",
		];
		for(var i in Keys)
		{
			var name = Keys[i];
			if(data[name] !== undefined) root[name] = data[name];
		}

		Util.ModelClear(member.model);
		Util.ModelForeach(data.member_list, function(e){
			Util.ModelPush(member.model, e);
		});
	}
}
