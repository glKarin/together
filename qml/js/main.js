.pragma library

function IncludeJS(url, cb)
{
	var res = Qt.include(url, cb);
	var st = res["status"];
	switch(st)
	{
		case 1:
		 console.log("[DEBUG]: js file: '%1' is including.".arg(url));
		 break;
		case 2:
		 console.log("[ERROR]: js file: '%1' include fail on network.".arg(url));
		 break;
		case 3:
		 console.log("[ERROR]: js file: '%1' has error.".arg(url));
		 break;
		case 0:
		default:
		 console.log("[DEBUG]: js file: '%1' include successful.".arg(url));
		 break;
	}
	return st === 0;
}

IncludeJS("network.js");
IncludeJS("api.js");
IncludeJS("util.js");
IncludeJS("database.js");
IncludeJS("openrepos.js");

var _UT;
var globals;
//var db = new idDatabase("together", "Together database", 2 * 1024 * 1024);

function Init(object)
{
	_UT = object.u;
	globals = object.g;
}

function Reset()
{
	idAPI_HOST = "";
	idAPI.SetHost();
	_UT.SetReferer();
}

function Request(url, method, args, success, fail, type)
{
    var req = new idNetwork(url, method, args, type);

    req.Request(success, fail);
		return req;
}

function L(name)
{
	return _UT.Lang(name);
}

function HandleRetCode(code, func)
{
	var r = code != 0;
	var Strs = {
		"0": "成功",
		"-14": "ticket错误",
		"1": "传入参数错误",
		"1100": "未登录提示",
		"1101": "未检测到登录",
		"1102": "cookie值无效",
		"1203": "当前登录环境异常，为了安全起见请不要在web端进行登录",
		"1205": "操作频繁",
	};
	var codestr = code.toString();
	if(typeof(func) === "function" && r)
		func("[%1]: %2 -> %3".arg("ERROR").arg(code).arg(Strs[codestr] || "未知错误"));
	if(code == 1100 || code == 1101 || code == 1102)
	{
		globals._Login();
	}
	else if(code == 1203)
	{
		Qt.quit();
	}
	return r;
}

// LoginPage
function GetLoginUUID(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(text){
		var uuid = idAPI.MakeLoginUUID(text);
		if(uuid)
		{
			var d = {
				uuid: uuid,
			};
			if(typeof(success) === "function") success(d);
		}
		else
			f(json.message);
	}
	var opt = {
		appid: idWebAPI.APPID,
		fun: "new",
		lang: "zh_CN",
		_: Date.now(),
	};
	Request(idAPI.JSLOGIN, "GET", opt, s, f, "TEXT");
}

function GetQRCode(data, success, fail)
{
	var img = idAPI.QRCODE.arg(data.uuid);
	if(data.target !== undefined)
		img += "?t=" + data.target;
	if(typeof(success) === "function")
	{
		var d = {
			qrcode: img
		};
		success(d);
	}
	else
		return img;
}

function GetLoginState(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(text){
		var d = idAPI.MakeLoginState(text);
		if(d)
		{
			if(typeof(success) === "function") success(d);
		}
		else
			f(json.message);
	}
	var opt = {
		uuid: data.uuid,
		tip: data.state,
		_: Date.now(),
			//r: -
	};
	if(data.icon !== undefined)
		opt.loginicon = data.icon;
	Request(idAPI.LOGIN, "GET", opt, s, f, "TEXT");
}

function GetLoginRedirect(data, success, fail)
{
	// set host
	idAPI.SetHost(data.HOST); //k idAPI_HOST = idAPI.GetHost(data.HOST);
	var api = data.SCHEME + "://" + data.HOST + data.PATH;
	console.log("[Qml]: Set referer -> " + idAPI.MakeHost());
	_UT.SetReferer(idAPI.MakeHost(/*idAPI_HOST*/));

	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(text){
		var xml_data = idAPI.MakeLoginRedirect(text);
		if(!xml_data)
		{
			f("No data");
			return;
		}
		if(xml_data.type === "URL")
		{
			f("Redirect api version is wrong");
			return;
		}
		var obj = _UT.XML_Parse(xml_data.data);
		if(!obj || obj.children[0].children !== "0")
		{
			f("Get data error");
			return;
		}
		var unused = ["ret", "message", "isgrayscale"];
		var d = {
			url: api,
		};
		for(var i in obj.children)
		{
			var o = obj.children[i];
			if(unused.indexOf(o.tag) !== -1)
				continue;
			d[o.tag] = o.children;
		}

		if(typeof(success) === "function") success(d);
	}
	var opt = data.PARAMS;
	Request(api, "GET", opt, s, f, "TEXT");
}

// HomePage
function GetInitData(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(HandleRetCode(res, f))
		{
			return;
		}
		var k = json.SyncKey;
		var userinfo = new Object();
		if(!idAPI.MakeProfileInfo(json, userinfo))
		{
			f("Get user profile fail");
			return;
		}
		var contacts = [];
		idAPI.MakeHomeContact(json, contacts);
		for(var i in contacts)
		{
			var item = contacts[i];
			var c = MakeSessionId(userinfo.uname, item.uname);
			item.session = c.session;
		}
		var subscribes = [];
		idAPI.MakeHomeArticle(json, subscribes);
		var d = {
			userinfo: userinfo,
			synckey: k,
			data: contacts,
			subscribe_data: subscribes,
		};
		if(typeof(success) === "function") success(d);
	}
	var opt = JSON.stringify(globals._MakeBaseRequest());
	var get_opt = {
		pass_ticket: globals.pass_ticket,
		r: Date.now(),
	};
	Request(idAPI.MakeAPI(idAPI.INIT) + "?" + new idNetwork().MakeParams(get_opt), "POST", opt, s, f);
}

// ContactPage
function GetMyContact(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(HandleRetCode(res, f))
		{
			return;
		}
		var contacts = [];
		if(!idAPI.MakeMyContact(json, contacts))
		{
			f("Get my contact fail");
			return;
		}
		contacts.sort(function(a, b){
			return a.pinyin_head.charCodeAt(0) - b.pinyin_head.charCodeAt(0);
		});
		var push = Array.isArray(data.contactModel) ? "push" : "append";
		for(var i in contacts)
		{
			var item = contacts[i];
			data.contactModel[push](item);
		}
		var d = {
			count: json.MemberCount,
		};
		if(typeof(success) === "function") success(d);
	}
	var opt = JSON.stringify(globals._MakeBaseRequest());
	var get_opt = {
		pass_ticket: globals.pass_ticket,
		skey: globals.skey,
		r: Date.now(),
	};
	Request(idAPI.MakeAPI(idAPI.CONTACT) + "?" + new idNetwork().MakeParams(get_opt), "POST", opt, s, f);
}

// ProfilePage
function GetUserContact(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(HandleRetCode(res, f))
		{
			return;
		}
		var contacts = [];
		if(!idAPI.MakeUserContact(json, contacts))
		{
			f("Get my contact fail");
			return;
		}
		var d = {
			list: contacts,
		};
		if(typeof(success) === "function") success(d);
	}
	var opt = globals._MakeBaseRequest();
	opt.List = [];
	for(var i in data.list)
	{
		if(!data.list[i])
			continue;
		var item = {
			UserName: data.list[i],
			EncryChatRoomId: data["chatroomid"] || "",
		};
		opt.List.push(item);
	}
	opt.Count = opt.List.length;
	var get_opt = {
		pass_ticket: globals.pass_ticket,
		type: "ex",
	};
	Request(idAPI.MakeAPI(idAPI.BATCH) + "?" + new idNetwork().MakeParams(get_opt), "POST", JSON.stringify(opt), s, f);
}

// SessionPage
function GetSendData(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(HandleRetCode(res, f))
		{
			return;
		}
		if(typeof(success) === "function")
		{
			var d = new Object();
			if(!idAPI.MakeSendData(json, d))
			{
				f("Make send data fail");
				return;
			}
			success(d);
		}
	}
	var get_opt = {
		pass_ticket: globals.pass_ticket,
	};
	var opt = globals._MakeBaseRequest();
	opt.Msg = {
		Type: data.type,
		Content: data.content,
		FromUserName: globals.uname,
		ToUserName: data.uname,
		LocalID: data.local_id,
		ClientMsgId: data.local_id,
	};
	opt.Scene = 0;
	Request(idAPI.MakeAPI(idAPI.SEND) + "?" + new idNetwork().MakeParams(get_opt), "POST", JSON.stringify(opt), s, f);
}


// main
function GetCheckData(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var synckey = globals._MakeSyncKey();
	if(!synckey)
	{
		f("Wait login");
		return;
	}
	var s = function(text){
		var d = idAPI.MakeCheckData(text);
		if(d)
		{
			if(HandleRetCode(d.retcode, f))
				return;
			if(typeof(success) === "function") success(d);
		}
		else
			f(json.message);
	}
	var opt = {
		skey: globals.skey,
		sid: globals.wxsid,
		uin: globals.wxuin,
		deviceid: globals.deviceId,
		synckey: synckey,
		r: Date.now(),
		_: Date.now(),
	};
	Request(idAPI.MakeAPI(idAPI.CHECK) + "?" + new idNetwork().MakeParams(opt), "GET", undefined, s, f, "TEXT");
}

function GetSyncData(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(HandleRetCode(res, f))
		{
			return;
		}
		var IMG_H = 128;
		var msg = [];
		idAPI.MakeSyncData(json, msg);
		for(var i in msg)
		{
			var d = msg[i];
			var content = d.content;
			var mediaId = d.media_id;
			if(!d.media_id)
			{
				if(d.msg_type == 3 || d.msg_type == 34 || d.msg_type == 43)
					d.media_id = content;
			}
			if(d.msg_type == 3)
			{
				var p = CaleImageZoomFactory(d.img_width, d.img_height, IMG_H, IMG_H);
				if(p > 0)
				d.content = "<a href='_View_image'><img src='%1' width='%2' height='%3'/></a>".arg(idAPI.MakeThumbnailUrl(d.mid, globals.skey)).arg(d.img_width * p).arg(d.img_height * p);
				else
				d.content = "<a href='_View_image'><img src='%1' height='%2'/></a>".arg(idAPI.MakeThumbnailUrl(d.mid, globals.skey)).arg(IMG_H);
			}
			else if(d.msg_type == 43)
			{
				var p = CaleImageZoomFactory(d.img_width, d.img_height, IMG_H, IMG_H)
				if(p > 0)
				d.content = ("<a href='_Play_video'><img src='%1' width='%2' height='%3'><br/>" + L("Click to play video") + "(%4)</img></a>").arg(idAPI.MakeThumbnailUrl(d.mid, globals.skey)).arg(d.img_width * p).arg(d.img_height * p).arg(FormatDuration(d.play_length));
				else
				d.content = ("<a href='_Play_video'><img src='%1' height='%2'><br/>" + L("Click to play video") + "(%3)</img></a>").arg(idAPI.MakeThumbnailUrl(d.mid, globals.skey)).arg(IMG_H).arg(FormatDuration(d.play_length));
			}
			else if(d.msg_type == 34)
				d.content = ("<a href='_Play_audio'>" + L("Voice message") + "(%1)&nbsp;<img src='../../resc/icon_voice.png'/></a>").arg(FormatDuration(Math.ceil(d.voice_length / 1000)));
			else if(d.msg_type == 47)
			{
				var p = CaleImageZoomFactory(d.img_width, d.img_height, IMG_H, IMG_H)
				if(p > 0)
				d.content = "<a href='_View_emoji'><img src='%1' width='%2' height='%3'/></a>".arg(idAPI.MakeThumbnailUrl(d.mid, globals.skey, "big")).arg(d.img_width).arg(d.img_height);
				else
				d.content = "<a href='_View_emoji'><img src='%1' height='%2'/></a>".arg(idAPI.MakeThumbnailUrl(d.mid, globals.skey, "big")).arg(d.img_height);
			}
			else if(d.msg_type == 49)
				d.content = (L("File") + ": %1(%2)<br/><a href='_Down_files'>" + L("Click to download") + "</a>").arg(d.file_name).arg(FormatFileSize(d.file_size));
		}
		var d = {
			synckey: json.SyncKey,
			msgModel: msg,
		};
		if(typeof(success) === "function") success(d);
	}
	var get_opt = {
		skey: globals.skey,
		sid: globals.wxsid,
		uin: globals.wxuin,
	};
	var opt = globals._MakeBaseRequest();
	opt.SyncKey = globals.synckey;
	opt.rr = parseInt(-Date.now() / 1000);
	Request(idAPI.MakeAPI(idAPI.SYNC) + "?" + new idNetwork().MakeParams(get_opt), "POST", JSON.stringify(opt), s, f);
}

function GetLogout(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(text){
		if(typeof(success) === "function") success();
	}
	var get_opt = {
		redirect: 1,
		type: 1,
		skey: globals.skey,
	};
	var opt = {
		sid: globals.wxsid,
		uin: globals.wxuin,
	};
	Request(idAPI.MakeAPI(idAPI.LOGOUT) + "?" + new idNetwork().MakeParams(get_opt), "POST", opt, s, f, "TEXT");
}

function GetRevokeData(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(HandleRetCode(res, f))
		{
			return;
		}
		var d = new Object();
		idAPI.MakeRevokeInfo(json, d);
		if(typeof(success) === "function") success(d);
	}
	var get_opt = {
		pass_ticket: globals.pass_ticket,
	};
	var opt = globals._MakeBaseRequest();
	opt.ClientMsgId = data.local_id;
	opt.SvrMsgId = data.mid;
	opt.ToUserName = data.uname;
	Request(idAPI.MakeAPI(idAPI.REVOKE) + "?" + new idNetwork().MakeParams(get_opt), "POST", JSON.stringify(opt), s, f);
}

function GetSendImgData(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(HandleRetCode(res, f))
		{
			return;
		}
		if(typeof(success) === "function")
		{
			var d = new Object();
			if(!idAPI.MakeSendData(json, d))
			{
				f("Make send data fail");
				return;
			}
			success(d);
		}
	}
	var get_opt = {
		pass_ticket: globals.pass_ticket,
		fun: "async",
		f: "json",
	};
	var opt = globals._MakeBaseRequest();
	opt.Msg = {
		Type: 3,
		Content: "",
		FromUserName: globals.uname,
		ToUserName: data.uname,
		LocalID: data.local_id,
		ClientMsgId: data.local_id,
		MediaId: data.media_id,
	};
	opt.Scene = 0;
	Request(idAPI.MakeAPI(idAPI.IMAGE) + "?" + new idNetwork().MakeParams(get_opt), "POST", JSON.stringify(opt), s, f);
}

function GetSendVideoData(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(HandleRetCode(res, f))
		{
			return;
		}
		if(typeof(success) === "function")
		{
			var d = new Object();
			if(!idAPI.MakeSendData(json, d))
			{
				f("Make send data fail");
				return;
			}
			success(d);
		}
	}
	var get_opt = {
		pass_ticket: globals.pass_ticket,
		fun: "async",
		f: "json",
	};
	var opt = globals._MakeBaseRequest();
	opt.Msg = {
		Type: 43,
		Content: "",
		FromUserName: globals.uname,
		ToUserName: data.uname,
		LocalID: data.local_id,
		ClientMsgId: data.local_id,
		MediaId: data.media_id,
	};
	opt.Scene = 0;
	Request(idAPI.MakeAPI(idAPI.VIDEO) + "?" + new idNetwork().MakeParams(get_opt), "POST", JSON.stringify(opt), s, f);
}

function GetSendFileData(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(HandleRetCode(res, f))
		{
			return;
		}
		if(typeof(success) === "function")
		{
			var d = new Object();
			if(!idAPI.MakeSendData(json, d))
			{
				f("Make send data fail");
				return;
			}
			success(d);
		}
	}
	var get_opt = {
		pass_ticket: globals.pass_ticket,
		fun: "async",
		f: "json",
	};
	var opt = globals._MakeBaseRequest();
	opt.Msg = {
		Type: 6,
		Content: "<appmsg appid='%1' sdkver=''><title>%2</title><des></des><action></action><type>6</type><content></content><url></url><lowurl></lowurl><appattach><totallen>%3</totallen><attachid>%4</attachid><fileext>%5</fileext></appattach><extinfo></extinfo></appmsg>".arg(idAPI.APPID).arg(data.file_name).arg(data.file_size.toFixed()).arg(data.media_id).arg(data.file_suffix),
		FromUserName: globals.uname,
		ToUserName: data.uname,
		LocalID: data.local_id,
		ClientMsgId: data.local_id,
		MediaId: data.media_id,
	};
	opt.Scene = 0;
	Request(idAPI.MakeAPI(idAPI.FILES) + "?" + new idNetwork().MakeParams(get_opt), "POST", JSON.stringify(opt), s, f);
}

function GetSendEmojiData(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(HandleRetCode(res, f))
		{
			return;
		}
		if(typeof(success) === "function")
		{
			var d = new Object();
			if(!idAPI.MakeSendData(json, d))
			{
				f("Make send data fail");
				return;
			}
			success(d);
		}
	}
	var get_opt = {
		pass_ticket: globals.pass_ticket,
		fun: "sys",
		lang: "zh_CN"
	};
	var opt = globals._MakeBaseRequest();
	opt.Msg = {
		Type: 47,
		EmojiFlag: 2,
		FromUserName: globals.uname,
		ToUserName: data.uname,
		LocalID: data.local_id,
		ClientMsgId: data.local_id,
		MediaId: data.media_id,
	};
	opt.Scene = 0;
	Request(idAPI.MakeAPI(idAPI.EMOJI) + "?" + new idNetwork().MakeParams(get_opt), "POST", JSON.stringify(opt), s, f);
}

function GetSendMediaData(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	if(!globals._IsValid())
	{
		f("Not login");
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(HandleRetCode(res, f))
		{
			return;
		}
		if(typeof(success) === "function")
		{
			var d = new Object();
			if(!idAPI.MakeSendData(json, d))
			{
				f("Make send data fail");
				return;
			}
			success(d);
		}
	}

	var type = 6;
	var api = idAPI.FILES;
	if(data.msg_type == 3)
	{
		type = 3;
		api = idAPI.IMAGE;
	}
	else if(data.msg_type == 43)
	{
		type = 43;
		api = idAPI.VIDEO;
	}
	else if(data.msg_type == 47)
	{
		type = 47;
		api = idAPI.EMOJI;
	}
	var content = type == 6 ? "<appmsg appid='%1' sdkver=''><title>%2</title><des></des><action></action><type>6</type><content></content><url></url><lowurl></lowurl><appattach><totallen>%3</totallen><attachid>%4</attachid><fileext>%5</fileext></appattach><extinfo></extinfo></appmsg>".arg(idAPI.APPID).arg(data.file_name).arg(data.file_size.toFixed()).arg(data.media_id).arg(data.file_suffix) : "";

	var get_opt = {
		pass_ticket: globals.pass_ticket,
		fun: type === 47 ? "sys" : "async",
		f: "json",
		lang: "zh_CN",
	};
	var opt = globals._MakeBaseRequest();
	opt.Msg = {
		Type: type,
		FromUserName: globals.uname,
		ToUserName: data.uname,
		LocalID: data.local_id,
		ClientMsgId: data.local_id,
		MediaId: data.media_id,
	};
	if(type === 47)
		opt.Msg.EmojiFlag = 2;
	else
		opt.Msg.Content = content;
	opt.Scene = 0;
	Request(idAPI.MakeAPI(api) + "?" + new idNetwork().MakeParams(get_opt), "POST", JSON.stringify(opt), s, f);
}



// media
function GetMediaUrl(type, mid)
{
	var a = "";
	var opt = {
		skey: globals.skey,
	};
	switch(type)
	{
		case 3: 
			a = idAPI.MEDIA_IMAGE; 
			opt.MsgID = mid;
			break;
		case 34: 
			a = idAPI.MEDIA_VOICE; 
			opt.msgid = mid;
			break;
		case 43: 
			a = idAPI.MEDIA_VIDEO; 
			opt.msgid = mid;
			break;
		case 47: 
			a = idAPI.MEDIA_IMAGE; 
			opt.MsgID = mid;
			opt.type = "big";
			break;
		default:
			break;
	}
	if(a === "")
		return false;

	return idAPI.MakeAPI(a) + "?" + new idNetwork().MakeParams(opt);
}

function GetFileUrl(media_id, file_name)
{
	var opt = {
		//mediaid: media_id, // mediaid not encode for @
		sender: "",
		fromuser: "",
		pass_ticket: globals.pass_ticket,
		webwx_data_ticket: globals.webwx_data_ticket,
		encryfilename: file_name,
	};
	return idAPI.MakeAPI(idAPI.MEDIA_FILES) + "?" + new idNetwork().MakeParams(opt) + "&mediaid=" + media_id;
}

function GetDownloadUrl(type, mid, mediaId, fileName)
{
	if(type == 3 || type == 34 || type == 43 || type == 47)
	{
		return GetMediaUrl(type, mid);
	}
	else if(type == 49)
	{
		return GetFileUrl(mediaId, fileName);
	}
	return false;
}

function GetUploadUrl(type)
{
	return idAPI.MakeAPI(idAPI.MEDIA_UPLOAD) + "?f=json";
}

function GetAvatarUrl(uname, roomid)
{
	var opt = {
		seq: 0,
		username: uname,
		skey: globals.skey
	};

	var g = idAPI.IsGroupUname(uname);
	if(roomid && !g)
		opt.chatroomid = roomid;
	return idAPI.MakeAPI(g ? idAPI.HEADIMG : idAPI.ICON) + "?" + new idNetwork().MakeParams(opt, false);
}



function SyncOpenRepos(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var a = new Object();
		var res = idOpenRepos.LoadApplication(json, a);
		if(typeof(res) === "string")
		{
			f(res);
			return;
		}
		if(typeof(success) === "function") success(a);
	};

	Request(idOpenRepos.MakeAPIUrl(idOpenRepos.APP_DETAIL.arg(data.appid)), "GET", undefined, s, f);
}



// other
var SPLIT = "|";
function MakeSessionId(from, to)
{
	//var c = from.localeCompare(to); // sort by string
	var c = from === globals.uname || !globals.uname ? -1 : 1; // my uname|other uname
	var session = c > 0 ? to + SPLIT + from : from + SPLIT + to;
	var type = c > 0 ? 1 : 0;
	return {
		session: session,
		type: type,
	};
}

function __GetPageData(obj, props)
{
	var r = {
		pageNo: 1,
		pageSize: 0,
		pageCount: 0,
		totalCount: 0,
	};
	if(obj)
	{
		if(props[0]) r.pageNo = obj[props[0]] || r.pageNo;
		if(props[1]) r.pageSize = obj[props[1]] || r.pageSize;
		if(props[2]) r.totalCount = obj[props[2]] || r.totalCount;

		if(props[3])
			r.pageCount = obj[props[3]] || r.pageCount;
		else
			r.pageCount = r.pageSize !== 0 ? Math.ceil(r.totalCount / r.pageSize) : 0;
	}
	return r;
}

// test
function TEST(data, success, fail)
{
}
