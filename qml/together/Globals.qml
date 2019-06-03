import QtQuick 1.1

QtObject{
	id: root;

	objectName: "idGlobalsObject";
	property string uuid;

	property string skey;
	property string wxsid;
	property string wxuin;
	property string pass_ticket;

	// in cookie
	property string webwx_data_ticket;
	property string webwx_auth_ticket;

	property string deviceId;

	// user info
	property string uid;
	property string nickname;
	property string uname;
	property int sex;
	property string avatar;
	property string signature;

	property variant synckey;
	property bool logined: false;

	function _Dump()
	{
		if(!_IsValid()) return;
		var data = {
			user_info: new Object(),
			login_info: new Object(),
		};
		var Login_Keys = ["skey", "wxsid", "wxuin", "pass_ticket",
		"webwx_data_ticket", "webwx_auth_ticket",
		"deviceId",
		];
		for(var i in Login_Keys)
		{
			data.login_info[Login_Keys[i]] = root[Login_Keys[i]];
		}

		var User_Keys = [
		"uid", "uname", "nickname", "sex", "avatar", "signature",
		];
		for(var i in User_Keys)
		{
			data.user_info[User_Keys[i]] = root[User_Keys[i]];
		}

		_PIPELINE.SetLoginData(data);
	}

	function _Restore()
	{
		var data = _PIPELINE.GetLoginData();
		if(!data) return;

		var Login_Keys = ["skey", "wxsid", "wxuin", "pass_ticket",
		"webwx_data_ticket", "webwx_auth_ticket",
		"deviceId",
		];
		for(var i in Login_Keys)
		{
			root[Login_Keys[i]] = data.login_info[Login_Keys[i]];
		}

		var User_Keys = [
		"uid", "uname", "nickname", "sex", "avatar", "signature",
		];
		for(var i in User_Keys)
		{
			root[User_Keys[i]] = data.user_info[User_Keys[i]];
		}

		logined = _IsValid();
	}

	function _SetLoginData(data)
	{
		var Keys = ["skey", "wxsid", "wxuin", "pass_ticket",
			"webwx_data_ticket", "webwx_auth_ticket"
		];
		for(var i in Keys)
		{
			root[Keys[i]] = data[Keys[i]];
		}

		logined = _IsValid();
	}

	function _SetUserInfo(data)
	{
		var Keys = [
			"uid", "uname", "nickname", "sex", "avatar", "signature"
		];
		for(var i in Keys)
		{
			root[Keys[i]] = data[Keys[i]];
		}
	}

	function _IsValid()
	{
		var Keys = ["skey", "wxsid", "wxuin", "pass_ticket",
			"webwx_data_ticket", "webwx_auth_ticket"
		];
		for(var i in Keys)
		{
			if(!root[Keys[i]]) return false;
		}
		return true;
	}

	function _GetSexName(s)
	{
		if(s == 1) return qsTr("Male");
		else if(s == 2) return qsTr("Female");
		else return qsTr("Secret");
	}

	function _MakeSyncKey()
	{
		var arr = [];
		for(var i in synckey.List)
		{
			var e = synckey.List[i];
			arr.push(e.Key + "_" + e.Val);
		}
		return arr.join("|");
	}

	function _MakeBaseRequest()
	{
		var opt = {
			BaseRequest: {
				"Uin": globals.wxuin,
				"Sid": globals.wxsid,
				"Skey": globals.skey,
				"deviceId": globals.deviceId,
			},
		};
		return opt;
	}

	function _GetUserShownName(user)
	{
		var model = user ? user : root;
		//if(model.groupname) return model.groupname;
		if(model.markname) return("%1(%2)".arg(model.markname).arg(model.nickname));
		else return model.nickname;
	}

	function _IsGroup(n)
	{
		return(n.indexOf("@@") === 0);
	}

	function _Logout()
	{
		logined = false;
		appobj._Reset();

		var String_Keys = ["skey", "wxsid", "wxuin", "pass_ticket",
		"webwx_data_ticket", "webwx_auth_ticket",
		"deviceId",
		"uid", "uname", "nickname", "avatar", "signature",
		];
		for(var i in String_Keys)
		{
			root[String_Keys[i]] = "";
		}

		var Int_Keys = [
			"sex", 
		];
		for(var i in Int_Keys)
		{
			root[Int_Keys[i]] = 0;
		}

		_PIPELINE.SetLoginData(new Object());

		sessionmodel._Reset();
	}

	function _Login()
	{
		_Logout();
		pageStack.clear();
		controller._OpenLoginPage();
	}

	onSynckeyChanged: {
		_PIPELINE.SetSyncKey(synckey);
	}
}
