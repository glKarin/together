import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "component"
import "../js/main.js" as Script
import "../js/main.js" as Util

PageStackWindow {
	id: app;

	property int iStatusBarHeight: __statusBarHeight; // private property

	objectName: "idMainWindow";
	showStatusBar: inPortrait && !settings.bFullscreen;
	showToolBar: false;
	platformStyle: PageStackWindowStyle {
		cornersVisible: true;
	}
	initialPage: 
	SplashPage
	//SettingPage
	{
		id: mainpage
	}

	Connections{
		target: _UT;
		onHasUpdate: {
			var texts = [];
			var updates = _UT.Changelog().CHANGES;
			for(var i in updates)
			{
				texts.push({
					text: updates[i],
				});
			}
			controller._Info(
				qsTr("Info"),
				qsTr("Version") + ": " + version,
				texts,
				undefined,
				function(link){
					eval(link);
				}
			);
		}
	}

	Binding{
		target: theme;
		property: "inverted";
		value: constants._bInverted;
	}

	SessionModel{
		id: sessionmodel; // session model
	}

	QtObject{
		id: appobj;
		property bool __syncLock: false;

		function _GetCheckData()
		{
			function f(err)
			{
				console.log(err);
			}
			function s(data)
			{
				if(data.retcode == 0)
				{
					var selector = parseInt(data.selector);
					if(selector == 0) return;
					else if(selector == 6) return;
					// 2 new message
					// 4 modify contact
					// 6 add/delete contact
					// 7 enter/leave chat
					if(selector == 2)
					{
						if(!controller._IsCurrentPage("Session"))
						{
							_PIPELINE.ShowNotification(qsTr("Notification"), qsTr("You have a new message"));
						}
					}
					appobj._GetSyncData();
				}
			}
			Script.GetCheckData(undefined, s, f);
		}

		function _GetSyncData(force)
		{
			if(force) __syncLock = false;
			if(__syncLock) return;
			__syncLock = true;
			function f(err)
			{
				console.log(err);
				__syncLock = false;
			}
			function s(data)
			{
				globals.synckey = data.synckey;
				sessionmodel._MakeSessionData(data.msgModel);
				__syncLock = false;
			}
			Script.GetSyncData(undefined, s, f);
		}

		function _GetUserContact(uname, func)
		{
			function f(err)
			{
				controller._ShowMessage(err);
			}
			function s(data)
			{
				if(data.list) func(data.list[0]);
				else func(null);
			}
			var d = {
				list: [
					uname,
				],
			};
			Script.GetUserContact(d, s, f);
		}

	}

	Timer {
		id: synctimer;
		interval: (Qt.application.active ? Math.max(settings.iSyncInterval, 1) : Math.max(settings.iSyncBackground, 5)) * 1000;
		repeat: true;
		running: globals.logined;
		onTriggered: {
			appobj._GetCheckData();
		}
	}

	Constants{
		id: constants;
	}

	Globals{
		id: globals;
	}

	SettingsObject{
		id: settings;
	}

	Controller{
		id: controller;
	}

	InfoBanner{
		id: infobanner;
		topMargin: (app.showStatusBar ? iStatusBarHeight : 0) + constants._iSpacingLarge;
		leftMargin: constants._iSpacingMedium;
		z: constants._iMaxZ;
		function _ShowMessage(text)
		{
			infobanner.text = text;
			infobanner.show();
		}
	}

	Rectangle{
		id: statusbar;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		height: iStatusBarHeight;
		z: Number.MAX_VALUE;
		color: constants._cGlobalColor;
		opacity: 0.4;
		visible: app.showStatusBar && _UT.dev !== 0 && !settings.bFullscreen;
	}

 function _Beyond_Forever_Together()
 {
	 var n = new Date(), p = new Date(1993, 6 - 1, 30); var y = n.getFullYear() - p.getFullYear(), m = (n.getMonth() + 1) - (p.getMonth() + 1); if(m < 0) y -= 1;
	 controller._ShowMessage(_UT.Get("WONGKAKUI").arg(y));
 }

	Component.onCompleted: {
		_UT.CheckUpdate();
		Script.Init({
			u: _UT,
			g: globals,
		});

		globals.deviceId = Script.idAPI.MakeDeveceID();
		//mainpage._Init();
	}
}
