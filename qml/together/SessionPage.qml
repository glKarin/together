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
		obj._MakeUserSession(uname);
	}

	QtObject{
		id: obj;

		function _MakeUserSession(n)
		{
			var session = sessionmodel._GetSession(n);
			if(session)
			{
				view._SetCurrentSession(session);
			}
			else console.log("Session is not exists!");
		}

		function _GetSendData()
		{
			if(!input.sText) return;

			var s = function(data){
				sessionmodel._MakeSessionData([data]);
				input._Clear();
			};
			var f = function(err){
				controller._ShowMessage(err);
			};
			var d = {
				type: 1,
				content: input.sText,
				uname: sessionmodel.currentUname,
			};

			Script.GetSendData(d, s, f);
		}
	}

	SectionWidget{
		id: head;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		sText: sessionmodel.currentName;
		eTextAlign: constants._sAlignCenter;
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
				icon: "toolbar-new-email",
				script: "input._Paste();",
			},
			{
				icon: "toolbar-close",
				script: "input._Clear();",
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
			obj._GetSendData();
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
}
