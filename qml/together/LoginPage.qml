import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: qsTr("User");
	objectName: "idLoginPage";
	menus: mainmenu;

	function _Init()
	{
		obj._GetLoginUUID();
	}

	QtObject{
		id: obj;
		property string qrcode;
		property int state: 0;
		property string reqName;
		property int loginState: 0;

		function _GetLoginUUID()
		{
			root.bBusy = true;
			globals.uuid = "";
			qrcode = "";
			loginState = 0;

			var s = function(data){
				globals.uuid = data.uuid;
				obj.loginState = 1;
				obj._GetQRCode();
				root.bBusy = false;
			};
			var f = function(err){
				root.bBusy = false;
				obj.loginState = -1;
				controller._ShowMessage(err);
			};

			Script.GetLoginUUID(undefined, s, f);
		}

		function _GetQRCode()
		{
			if(globals.uuid == "") return;

			qrcode = "";
			var d = {
				uuid: globals.uuid,
				target: "webwx",
			};
			var s = function(data){
				obj.loginState = 2;
				reqName = _CONNECTOR.Request(data.qrcode, "FILE-QRCODE");
			};
			Script.GetQRCode(d, s);
		}

		function _GetLoginState()
		{
			if(globals.uuid == "") return;

			var d = {
				uuid: globals.uuid,
				state: state,
			};
			if(loginState == 2 || loginState == 3) d.icon = true;
			var s = function(data){
				var code = data.code;
				if(code == 201)
				{
					obj.state = 1;
					if((obj.loginState == 2 || obj.loginState == 3)&& data.userAvatar)
					{
						var d = data.userAvatar.match(/^data:img\/.+;base64,(.+)/);
						if(d)
						{
							var avatar = _UT.CacheFile(d[1], "LOGIN_AVATAR");
							if(avatar)
							{
								obj.qrcode = "file://" + avatar;
								obj.loginState = 4;
							}
						}
					}
					timer.restart();
				}
				else if(code == 200)
				{
					var params = _UT.ParseUrl(data.redirect_uri, "PARAMS");
				obj.loginState = 5;
				params.url = _UT.ParseUrl(data.redirect_uri, "SCHEME") + "://" + _UT.ParseUrl(data.redirect_uri, "HOST") + _UT.ParseUrl(data.redirect_uri, "PATH");
					obj._GetLoginRedirect(params);
				}
				else if(code == 408) // timeout
				{
					controller._ShowMessage(qsTr("Login timeout"));
					obj._GetLoginUUID();
				}
				else
				{
					timer.restart();
				}
			};
			var f = function(err){
				controller._ShowMessage(err);
				obj.loginState = -3;
			};

			Script.GetLoginState(d, s, f);
		}

		function _GetLoginRedirect(d)
		{
			if(globals.uuid == "") return;
			if(!d) return;

			root.bBusy = true;
			var s = function(data){
				var cookies = _UT.GetCookie(data.url);
				data["webwx_data_ticket"] = cookies["webwx_data_ticket"];
				data["webwx_auth_ticket"] = cookies["webwx_auth_ticket"];
				globals._SetLoginData(data);
				obj.loginState = 6;

				controller._ShowMessage(qsTr("Login successful!"));
				root.bBusy = false;
				obj._Rediect();
			};
			var f = function(err){
				controller._ShowMessage(err);
				obj.loginState = -4;
				root.bBusy = false;
			};

			Script.GetLoginRedirect(d, s, f);
		}

		function _GetLoginStateStr(n)
		{
			var States = [
				qsTr("Getting login uuid..."),
				qsTr("Getting login QRCode..."),
				qsTr("Downloading QRCode..."),
				qsTr("Using WeChat client scan the QRCode to login..."),
				qsTr("Click OK to login..."),
				qsTr("Login successful"),
				qsTr("Getting login data..."),
				// error
				qsTr("Can not login to web version"),
				qsTr("Get login QRCode fail"),
				qsTr("Get login uuid fail"),
			];
			return States[n >= 0 ? n : States.length + n];
		}

		function _Rediect()
		{
			if(pageStack.depth > 1)
			{
				pageStack.pop(undefined, true);
				pageStack.currentPage._Init();
			}
			else
				controller._OpenHomePage(true);
		}
	}

	Item{
		anchors.top: parent.top;
		anchors.bottom: img.top;
		anchors.bottomMargin: constants._iSpacingXXL;
		anchors.horizontalCenter: parent.horizontalCenter;
		width: parent.width;
		clip: true;
		Column{
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			spacing: constants._iSpacingLarge;
			SectionWidget{
				anchors.horizontalCenter: parent.horizontalCenter;
				sText: qsTr("Login");
				eTextAlign: constants._sAlignCenter;
			}
		}
	}

	Image{
		id: img;
		anchors.centerIn: parent;
		height: constants._iSizeTooBig;
		width: height;
		cache: false;
		smooth: true;
		sourceSize.width: width;
		sourceSize.height: height;
		source: obj.qrcode;
	}

	Column{
		anchors.top: img.bottom;
		anchors.bottom: parent.bottom;
		anchors.horizontalCenter: parent.horizontalCenter;
		anchors.topMargin: constants._iSpacingXXL;
		width: parent.width;
		spacing: constants._iSpacingLarge;
		clip: true;
		Text{
			width: parent.width;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			font.pixelSize: constants._iFontXXL;
			wrapMode: Text.WordWrap;
			color: obj.loginState >= 0 ? constants._cPrimaryColor : constants._cErrorColor;
			text: obj._GetLoginStateStr(obj.loginState);
		}

		Button{
			anchors.horizontalCenter: parent.horizontalCenter;
			visible: !root.bBusy;
			text: qsTr("Refresh");
			onClicked: {
				obj._GetLoginUUID();
			}
		}
	}

	Timer{
		id: timer;
		repeat: false;
		running: false;
		interval: 1000;
		onTriggered: {
			obj._GetLoginState();
		}
	}

	Connections{
		target: _CONNECTOR;
		onFinished: {
			if(obj.reqName === name)
			{
				if(error == 0)
				{
					obj.qrcode = value;
					obj.loginState = 3;
					obj._GetLoginState();
				}
				else
				{
					obj.loginState = -2;
				}
			}
			else controller._ShowMessage(value);
			obj.reqName = "";
		}
	}

	ContextMenu{
		id: mainmenu;
		MenuLayout {
			MenuItem{
				text: qsTr("Check update");
				onClicked: {
					appobj._CheckUpdate(true);
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

	Component.onCompleted: {
		//root._Init();
	}
}
