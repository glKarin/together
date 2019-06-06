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
	_UT.SetRequestHeader("Referer", "https://" + idAPI.MakeHost() + "/");
}

function Request(url, method, args, success, fail, type)
{
    var req = new idNetwork(url, method, args, type);

    req.Request(success, fail);
		return req;
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
	idAPI_HOST = idAPI.GetHost(data.HOST);
	var api = data.SCHEME + "://" + data.HOST + data.PATH;
	_UT.SetRequestHeader("Referer", "https://" + idAPI.MakeHost(idAPI_HOST) + "/");

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
			EncryChatRoomId: "",
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

			d.msg_type = data.type;
			d.from = globals.uname;
			d.to = data.uname;
			d.content = data.content;
			d.avatar = "";
			d.name = "";
			d.ts = Date.now() / 1000;
			d.ts_str= MakeTimestamp(d.ts);
			var c = MakeSessionId(d.from, d.to);
			d.session = c.session;
			d.type = c.type;
			d.group = idAPI.IsGroupUname(d.to) ? d.to : false;
			success(d);
		}
	}
	var id = "" + Date.now() + Random(1000, 9999);
	var get_opt = {
		pass_ticket: globals.pass_ticket,
	};
	var opt = globals._MakeBaseRequest();
	opt.Msg = {
		Type: data.type,
		Content: data.content,
		FromUserName: globals.uname,
		ToUserName: data.uname,
		LocalID: id,
		ClientMsgId: id,
		MedieId: data.media || "",
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
		var msg = [];
		idAPI.MakeSyncData(json, msg);
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
