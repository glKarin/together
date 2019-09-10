import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: qsTr("Session");
	objectName: "idSessionPage";
	menus: contacts;

	function _Init(uname)
	{
		sessionobj._MakeUserSession(uname);
	}

	QtObject{
		id: sessionobj;
		property string lastUname;

		function _MakeUserSession(n)
		{
			if(n && lastUname !== n)
			lastUname = n;

			var session = sessionmodel._GetSession(lastUname);
			if(session)
			{
				view._SetCurrentSession(session);
			}
			else console.log("Session is not exists!");
		}

		function _GetSendData()
		{
			if(!input.sText) return;

			var id = "" + Date.now() + Util.Random(1000, 9999);
			var d = {
				type: 1,
				content: input.sText,
				uname: sessionmodel.currentUname,
				local_id: id,
			};

			var c = Script.MakeSessionId(globals.uname, d.uname);
			var session = c.session;
			var ts = Date.now() / 1000;
			var data = {
				mid: 0,
				local_id: id,
				msg_type: d.type,
				from: globals.uname,
				to: d.uname,
				content: d.content,
				avatar: constants._sAvatarDefault,
				name: "",
				ts: ts,
				ts_str: Script.MakeTimestamp(ts),
				session: session,
				type: c.type,
				group: Script.idAPI.IsGroupUname(d.uname) ? d.uname : false,

				status: 1,
				progress: 0.0,
				file: "",
				file_size: 0,
				file_name: "",
				media_id: "",
				img_width: 0,
				img_height: 0,
				voice_length: 0,
				play_length: 0,
			};
			sessionmodel._MakeSessionData([data]);
			input._Clear();
			sessionmodel._SetModelValue("unsend", "");

			var s = function(ret_data){
				ret_data.status = 0;
				sessionmodel._UpdatePreProgress(session, ret_data.local_id, ret_data);
			};
			var f = function(err){
				controller._ShowMessage(err);
				sessionmodel._UpdatePreProgress(session, id, {status: 2});
			};

			Script.GetSendData(d, s, f);
		}

		function _ResendMsg(session, local_id, uname, text, msg_type)
		{
			if(!local_id) return;

			if(msg_type == 1)
			{
				var d = {
					type: 1,
					content: text,
					uname: uname,
					local_id: local_id,
				};
				sessionmodel._UpdatePreProgress(session, local_id, {status: 1});

				var s = function(ret_data){
					ret_data.status = 0;
					sessionmodel._UpdatePreProgress(session, ret_data.local_id, ret_data);
				};
				var f = function(err){
					controller._ShowMessage(err);
					sessionmodel._UpdatePreProgress(session, id, {status: 2});
				};

				Script.GetSendData(d, s, f);
			}
			else
			uploader._Load(session, local_id);
		}

		function _InsertEmoji(emojis)
		{
			input._Insert(emojis);
		}

		function _OpenMenu(data)
		{
			menu.text = data.content;
			menu.sender = data.from;
			menu.session = data.session;
			menu.mid = data.mid || "";
			menu.local_id = data.local_id || "";
			menu.receiver = data.to;
			menu.ts = data.ts;

			menu.open();
		}

		function _RemoveSession(del)
		{
			controller._Query(
				qsTr("WARNING"),
				qsTr("It will remove this session! Are you sure?"),
				qsTr("Remove"), qsTr("Cancel"),
				function(){
					sessionmodel[del ? "_DeleteSession" : "_RemoveSession"](sessionmodel.currentSession);
				}
			);
		}

		function _GetSendMediaData(path, msg_type, file_name)
		{
			if(!path) return;

			var info = _UT.GetFileInfo(path);
			var to = sessionmodel.currentUname;
			var id = "" + Date.now() + Util.Random(1000, 9999);
			var d = {
				Uin: globals.wxuin,
				Sid: globals.wxsid,
				Skey: globals.skey,
				DeviceID: globals.deviceId,
				FromUserName: globals.uname,
				ToUserName: to,
				webwx_data_ticket: globals.webwx_data_ticket,
				pass_ticket: globals.pass_ticket,
			};

			var name = file_name || "";
			var content = "";
			var type = msg_type;

			if(msg_type == 49)
			{
				if(info["MIME"] === "image/gif")
				type = 47;
				else if(info["TYPE"] === "image")
				type = 3;
				else if(info["TYPE"] === "video")
				type = 43;
			}
			if(type == 3)
				content = "<a href='_View_local_image'><img src='%1' height='%2'></img></a>".arg(path).arg(constants._iSizeXXXL);
			else if(type == 43)
				content = "%2: %1<br/><a href='_Play_local_video'>%3</a>".arg(name).arg(qsTr("Video")).arg(qsTr("Play"));
			else if(type == 47)
				content = "<a href='_View_local_emoji'><img src='%1' height='%2'></img></a>".arg(path).arg(constants._iSizeXXL);
			else
				content = "%2: %1<br/><a href='_Down_local_files'>%3</a>".arg(name).arg(qsTr("File")).arg(qsTr("Open"));

			var c = Script.MakeSessionId(globals.uname, to);
			var session = c.session;
			var ts = Date.now() / 1000;
			var data = {
				mid: 0,
				local_id: id,
				msg_type: type,
				from: globals.uname,
				to: to,
				content: content,
				avatar: constants._sAvatarDefault,
				name: "",
				ts: ts,
				ts_str: Script.MakeTimestamp(ts),
				session: session,
				type: c.type,
				group: Script.idAPI.IsGroupUname(to) ? to : false,

				status: 1,
				progress: 0.0,
				file: path,
				file_size: info["SIZE"],
				file_name: info["FILE_NAME"],
				media_id: "",
				img_width: 0,
				img_height: 0,
				voice_length: 0,
				play_length: 0,
			};
			sessionmodel._MakeSessionData([data]);

			uploader._Load(session, id, type, path, d);
		}

		function _RevokeMsg(session, mid, local_id, to)
		{
			if(!session || !mid || !to/* || !local_id*/) return;

			var d = {
				mid: mid,
				uname: to,
				local_id: local_id || "",
			};

			sessionmodel._UpdateProgress(session, mid, {status: 1});

			var s = function(ret_data){
				//sessionmodel._UpdateProgress(session, mid, {status: -1/*, content: qsTr("You revoke a message")*/});
			};
			var f = function(err){
				controller._ShowMessage(err + " " + qsTr("Only revoke messages that less than 2 minutes"));
				sessionmodel._UpdateProgress(session, mid, {status: 0});
			};

			Script.GetRevokeData(d, s, f);
		}
	}

	SectionWidget{
		id: head;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		sText: sessionmodel.currentName;
		eTextAlign: constants._sAlignCenter;
		Column{
			anchors.top: parent.top;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.rightMargin: constants._iSizeXXL;
			spacing: constants._iSpacingMedium;
			ToolIcon{
				height: parent.height;
				width: height;
				iconId: "toolbar-contact";
				enabled: Script.idAPI.IsGroupUname(sessionmodel.currentUname);
				visible: enabled;
				onClicked: {
					if(Script.idAPI.IsGroupUname(sessionmodel.currentUname))
					controller._OpenGroupMemberDialog(sessionmodel.currentUname, sessionmodel._GetModelValue("chatroomid"), function(uname, roomid, nickname){
						controller._OpenUserPage(uname + (roomid ? " " + roomid : ""));
					});
				}
			}
		}
	}

	SessionTabWidget{
		id: view;
		anchors.top: head.bottom;
		anchors.bottom: toolbars.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
	}

	ToolbarWidget{
		id: toolbars;
		anchors.bottom: input.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		model: [
			{
				icon: "toolbar-grid",
				script: "controller._OpenEmojiChooser(sessionobj._InsertEmoji);",
			},
			{
				icon: "toolbar-gallery",
				script: "controller._OpenImageChooser(function(path, name) { sessionobj._GetSendMediaData(path, _UT.GetFileInfo(path, 'MIME') === 'image/gif' ? 47 : 3, name); });",
			},
			{
				icon: "toolbar-add",
				script: "controller._OpenCameraPage(function(path) { sessionobj._GetSendMediaData(path, 3); }, true);",
			},
			{
				icon: "toolbar-volume",
				script: "controller._OpenVoiceRecorder(function(path, name) { sessionobj._GetSendMediaData(path, 49, name); });",
			},
			{
				icon: "toolbar-mediacontrol-play",
				script: "controller._OpenVideoChooser(function(path, name) { sessionobj._GetSendMediaData(path, 43, name); });",
			},
			{
				icon: "toolbar-attachment",
				script: "controller._OpenFileChooser(function(path, name) { sessionobj._GetSendMediaData(path, 49, name); });",
			},
			{
				icon: "toolbar-new-email",
				script: "input._Paste();",
			},
			{
				icon: "toolbar-close",
				script: "input._Clear();",
			},
			{
				icon: "toolbar-edit",
				script: "input._Select();",
			},
			{
				icon: "toolbar-trim",
				script: "input._Cut();",
			},
			{
				icon: "toolbar-share",
				script: "input._Copy();",
			},
			{
				icon: "toolbar-delete",
				script: "sessionobj._RemoveSession(false);",
			},
			{
				icon: "toolbar-settings",
				script: "controller._OpenSettingPage();",
			},
		]
	}

	EditWidget{
		id: input;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		sText: sessionmodel.currentUnsend;
		onSure: {
			input._MakeFocus();
			sessionobj._GetSendData();
		}
	}

	ContactMenuWidget{
		id: contacts;
		anchors.fill: parent;
		function open()
		{
			_Toggle(true);
		}
	}
	
	Connections{
		target: sessionmodel;
		onCurrentChanged: {
			input.sText = unsend;
			view._SetCurrentSession(session);
		}
		onPreChange: {
			sessionmodel._SetModelValue("unsend", input.sText, index);
		}
	}

	onIconClicked: {
		if(icon == 1)
		{
			sessionmodel._SetModelValue("unsend", input.sText);
			sessionmodel._SyncCurrent(-1);
		}
	}

	ContextMenu{
		id: menu;
		property string session;
		property string mid;
		property string local_id;
		property string text;
		property string sender;
		property string receiver;
		property int ts;

		MenuLayout{
			MenuItem{
				text: qsTr("Copy");
				enabled: menu.text !== "";
				visible: enabled;
				onClicked: {
					if(menu.text !== "")
					controller._CopyToClipboard(menu.text, qsTr("Content"));
				}
			}
			MenuItem{
				text: qsTr("Revoke");
				enabled: menu.sender === globals.uname && menu.session && menu.mid;
				//  && (Date.now() / 1000 - menu.ts <= 120); // if system time is different from server time, must record local time when message is send finished.
				// && menu.local_id // if message from other device, local_id is empty. but also can revoke it.
				visible: enabled;
				onClicked: {
					if(menu.session && menu.mid/* && menu.local_id*/)
					sessionobj._RevokeMsg(menu.session, menu.mid, menu.local_id, menu.receiver);
				}
			}
			MenuItem{
				text: qsTr("Delete");
				enabled: menu.sender === globals.uname;
				visible: enabled;
				onClicked: {
					if(menu.session && (menu.mid || menu.local_id))
					sessionmodel._RemoveMsg(menu.session, menu.mid, menu.local_id);
				}
			}
		}

		/*
		onStatusChanged: {
			if(status == DialogStatus.Closing)
			{
				menu.text = "";
				menu.sender = "";
				menu.session = "";
				menu.mid = "";
				menu.local_id = "";
			}
		}
		*/
	}

	Component.onDestruction: {
		//voice._Close();
	}

	onStatusChanged: {
		if(status === PageStatus.Deactivating)
		{
			sessionobj.lastUname = sessionmodel.currentUname;
			voice._Close();
		}
		else if(status === PageStatus.Activating)
		{
			if(sessionobj.lastUname)
			{
				sessionmodel._SyncCurrent(sessionobj.lastUname);
				sessionobj._MakeUserSession();
			}
		}
	}
}
