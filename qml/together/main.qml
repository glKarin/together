import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

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
	{
		id: mainpage
	}

	Connections{
		target: _UT;
		onHasUpdate: {
			appobj._ShowUpdates(version);
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

	VoiceWidget{
		id: voice;
	}

	Connections{
		id: transfer;
		target: _TRANSFER;
		property string __sessionId;
		property string __msgId;

		onDownloadStarted: {
			sessionmodel._UpdateProgress(sessionId, msgId, {
				status: 1,
			});
		}
		onDownloadProgress: {
			sessionmodel._UpdateProgress(sessionId, msgId, {
				status: 1,
				progress: progress,
			});
		}
		onDownloadFinished: {
			var p = {
				status: error == 0 ? 0 : 2,
			};
			if(error == 0)
			{
				var task = _TRANSFER.GetTaskValue(msgId);
				p.file = task ? task["FILE_PATH"] : "";
			}
			sessionmodel._UpdateProgress(sessionId, msgId, p);
			transfer._End(sessionId, msgId, error);
		}

		function _Load(sessionId, msgId, mediaId, msgType, fileName, open)
		{
			if(!sessionId || !msgId) return;

			if(open)
			{
				transfer.__sessionId = sessionId;
				transfer.__msgId = msgId;
			}

			var task = _TRANSFER.GetTaskValue(msgId);
			if(!task)
			{
				var url = Script.GetDownloadUrl(msgType, msgId, mediaId, fileName);
				console.log("[Qml]: Media url -> " + url);
				_TRANSFER.Download(url, msgId, mediaId, msgType, sessionId, fileName);
			}
			else
			{
				var status = task["STATUS"];
				if(status == 2)
				{
					console.log("[Qml]: File has transfered -> " + task["FILE_PATH"]);
					_Open(task["FILE_PATH"], msgType);
				}
				else if(status == 3)
				{
					_TRANSFER.Retransfer(msgId);
				}
				else
				{
					controller._ShowMessage(qsTr("File is transfering."));
				}
			}
		}

		function _End(sessionId, msgId, error)
		{
			if(sessionId !== transfer.__sessionId || msgId !== transfer.__msgId)
			{
				controller._ShowMessage(qsTr("File download successful."));
				return;
			}

			transfer.__sessionId = "";
			transfer.__msgId = "";

			if(error != 0)
			{
				controller._ShowMessage(qsTr("File download error."));
				return;
			}

			var task = _TRANSFER.GetTaskValue(msgId);
			if(!task)
			{
				controller._ShowMessage(qsTr("File download error."));
				return;
			}

			if(task["STATUS"] != 2)
			{
				controller._ShowMessage(qsTr("File download error."));
				return;
			}

			_Open(task["FILE_PATH"], task["MSG_TYPE"], true);
		}

		function _Open(url, msgType, from_download_finished)
		{
			var p = "file://" + url;
			if(msgType == 3)
			controller._OpenImageViewer(p);
			else if(msgType == 43)
			controller._OpenVideoPlayer(p);
			else if(msgType == 34)
			voice._Load(p);
			else if(msgType == 47)
			controller._OpenImageViewer(p);
			else if(msgType == 49)
			{
				if(from_download_finished)
				controller._ShowMessage(qsTr("File download successful. File path is ") + url);
				else
				Qt.openUrlExternally(p);
			}
		}
	}

	Connections{
		id: uploader;
		target: _TRANSFER;

		onUploadStarted: {
			sessionmodel._UpdatePreProgress(sessionId, msgId, {
				status: 1,
			});
		}
		onUploadProgress: {
			sessionmodel._UpdatePreProgress(sessionId, msgId, {
				status: 1,
				progress: progress,
			});
		}
		onUploadFinished: {
			sessionmodel._UpdatePreProgress(sessionId, msgId, {
				status: error == 0 ? 0 : 2,
			});
			uploader._End(sessionId, msgId, error);
		}

		function _Load(sessionId, localId, msgType, path, params)
		{
			if(!sessionId || !localId) return;

			var task = _TRANSFER.GetTaskValue(localId);
			if(!task)
			{
				if(path && params)
				{
					var url = Script.GetUploadUrl(msgType);
					console.log("[Qml]: File url -> " + path);
					_TRANSFER.Upload(url, path, localId, msgType, sessionId, params);
				}
			}
			else
			{
				var status = task["STATUS"];
				if(status == 2)
				{
					console.log("[Qml]: File has uploaded -> " + task["FILE_PATH"]);
					_Open(task["SESSION"], task["MEDIA_ID"], task["MSG_ID"], task["MSG_TYPE"], task["UNAME"], task["FILE_PATH"]);
				}
				else if(status == 3)
				{
					_TRANSFER.Retransfer(localId);
				}
				else
				{
					controller._ShowMessage(qsTr("File is uploading."));
				}
			}
		}

		function _End(sessionId, msgId, error)
		{
			if(error != 0)
			{
				controller._ShowMessage(qsTr("File upload error."));
				return;
			}

			var task = _TRANSFER.GetTaskValue(msgId);
			if(!task)
			{
				controller._ShowMessage(qsTr("File upload error."));
				return;
			}

			if(task["STATUS"] != 2)
			{
				controller._ShowMessage(qsTr("File upload error."));
				return;
			}

			_Open(task["SESSION"], task["MEDIA_ID"], task["MSG_ID"], task["MSG_TYPE"], task["UNAME"], task["FILE_PATH"]);
		}

		function _Open(session, media_id, local_id, msg_type, to, file)
		{
			var d = {
				msg_type: msg_type,
				uname: to,
				local_id: local_id,
				media_id: media_id,
			};

			if(msg_type == 49)
			{
				var info = _UT.GetFileInfo(file);
				d.file_size = info["SIZE"] || 0;
				d.file_name = info["FILE_NAME"] || "";
				d.file_suffix = info["SUFFIX"] || "";
			}

			sessionmodel._UpdatePreProgress(session, local_id, {status: 1});
			var s = function(ret_data){
				ret_data.status = 0;
				sessionmodel._UpdatePreProgress(session, ret_data.local_id, ret_data);
			};
			var f = function(err){
				controller._ShowMessage(err);
				sessionmodel._UpdatePreProgress(session, local_id, {status: 2});
			};

			Script.GetSendMediaData(d, s, f);
		}
	}

	SubscribeModel{
		id: subscribemodel;
	}

	QtObject{
		id: appobj;
		property int __syncLock: 0;
		property variant dialog: null;

		function _GetCheckData()
		{
			if(__syncLock !== 0) return;

			function f(err)
			{
				console.log(err);
				appobj.__Unlock();
			}
			function s(data)
			{
				if(data.retcode == 0)
				{
					var selector = parseInt(data.selector);
					if(selector == 0)
					{
						appobj.__Unlock();
						return;
					}
					// else not return, because synckey will changed when next get sync data.
					// 2 new message
					// 4 modify contact
					// 6 add/delete contact
					// 7 enter/leave chat
					//k if(selector == 2) { }
					appobj.__syncLock = 2;
					appobj._GetSyncData(); // get new sync key
				}
				else
				appobj.__Unlock();
			}
			appobj.__syncLock = 1;
			Script.GetCheckData(undefined, s, f);
		}

		function _GetSyncData()
		{
			if(__syncLock !== 2) return;
			__syncLock = 3;
			function f(err)
			{
				console.log(err);
				appobj.__Unlock();
			}
			function s(data)
			{
				if(appobj.__syncLock !== 3) return;
				globals.synckey = data.synckey;
				sessionmodel._MakeSessionData(data.msgModel);
				appobj.__Unlock();
			}
			Script.GetSyncData(undefined, s, f);
		}

		function _GetUserContact(uname, func, chatroomid)
		{
			var b = Array.isArray(uname);
			function f(err)
			{
				controller._ShowMessage(err);
			}
			function s(data)
			{
				if(data.list)
				{
					if(b)
					func(data.list);
					else
					func(data.list[0]);
				}
				else func(null);
			}
			var d = {
				list: b ? uname : [ uname ],
				chatroomid: chatroomid || "",
			};
			Script.GetUserContact(d, s, f);
		}

		function _Reset()
		{
			__syncLock = 0;
		}

		function __Unlock()
		{
			__syncLock = 0;
		}

		function _Online(msg)
		{
			function f(err)
			{
				console.log(err);
			}
			var d = {
				type: 1,
				content: msg ? msg : "",
				uname: "filehelper", // weixin filehelper: weixintuandui / wenjianchuanshuzhushou, uname is fixed
			};

			Script.GetSendData(d, undefined, f);
		}

		function _Notify(c)
		{
			if(!controller._IsCurrentPage("Session") || !Qt.application.active)
			{
				if(settings.bShowNotification)
				_PIPELINE.ShowNotification(qsTr("Notification"), qsTr("You have %1new message").arg(c !== undefined ? "" + c + qsTr(" ") : ""));
			}
		}

		function _CheckUpdate(showmsg)
		{
			var showmsg_f = function(msg){
				if(showmsg) controller._ShowMessage(msg);
				else console.log(msg);
			};
			showmsg_f(qsTr("Check update"));
			var s = function(data){
				if(!data.package_name && !data.package_version) // downed
				{
					controller._ShowMessage(qsTr("This app is downed. You should not continue to run it. Please contact to author for more."));
					return;
				}
				if(data.package_name !== _UT.Get("PKG"))
				{
					controller._ShowMessage(qsTr("This app is not upload to OpenRepos."));
					return;
				}

				var v = _UT.Get("VER");
				//v = "2014.0.3harmattan1";
				var o = data.package_version.substring(0, v.length);
				var u = o.localeCompare(v);
				console.log(v, o, u);
				if(u === 0)
				{
					showmsg_f(qsTr("Your app is newest version now"));
				}
				else if(u < 0)
				{
					showmsg_f(qsTr("Your app is newer than OpenRepos! Maybe your app is installed by other ways or other developer, and maybe this version is not upload to OpenRepos by developer now."));
				}
				else // update
				{
					showmsg_f(qsTr("Your app is older than OpenRepos! You need to update version."));
					var texts = [
						{
							text: "<img src='" + data.icon + "'/>",
						},
						{
							text: qsTr("Release") + ": " + Util.FormatDateTime(data.updated),
						},
						{
							text: qsTr("Developer") + ": " + "<a href='controller._OpenUrl(\"" + Script.idOpenRepos.MakeUserHomeUrl(data.user_name) + "\", 1);'>" + data.user_name + "</a>",
						},
						{
							text: qsTr("Changelog") + ": " + data.changelog,
						},
						{
							text: qsTr("Downloads") + ": " + data.download,
						},
						{
							text: qsTr("Description") + ": " + data.body,
						},
					];
					appobj.dialog = controller._Info(
						qsTr("New update"),
						data.package_version,
						texts,
						"<a href='controller._OpenUrl(\"" + data._url + "\", 1);'>" + qsTr("Update") + "</a>"
						+ " <a href='controller._CopyToClipboard(\"" + data._url + "\", \"" + qsTr("App detail URL") + "\");'>" + qsTr("Copy URL") + "</a>",
						function(link){
							if(appobj.dialog) appobj.dialog.accept();
							eval(link);
							appobj.dialog = null;
						},
						undefined,
						function(link){
							if(appobj.dialog) appobj.dialog.accept();
							eval(link);
							appobj.dialog = null;
						}
					);
				}
			};
			var f = function(err){
				controller._ShowMessage(err);
			};

			var d = {
				appid: _UT.Get("APPID"),
			};

			Script.SyncOpenRepos(d, s, f);
		}

		function _ShowUpdates(version)
		{
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

	Timer {
		id: synctimer;
		interval: (Qt.application.active ? Math.max(settings.iSyncInterval, 1) : Math.max(settings.iSyncBackground, 5)) * 1000;
		repeat: true;
		running: globals.logined;
		onTriggered: {
			appobj._GetCheckData();
		}
	}

	Timer {
		id: onlinetimer;
		interval: settings.iOnlineBackground * 60 * 1000;
		repeat: true;
		running: globals.logined && settings.bOnlineCheck;
		onTriggered: {
			appobj._Online();
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

		if(settings.bCheckUpdate)
		{
			appobj._CheckUpdate();
		}
		globals.deviceId = Script.idAPI.MakeDeveceID();
		//mainpage._Init();
	}
}
