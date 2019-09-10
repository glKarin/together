.pragma library

Qt.include("util.js");

var idAPI_HOST = ""; // UNUSED
var idAPI_Domain = "wx.qq.com";
var idAPI_SCHEME = "https://";

var __JSON_Print = function(json)
{
	console.log(JSON.stringify(json));
};

function MakeTimestamp(ts)
{
	var d = new Date(ts * 1000);
	var today = new Date();
	today.setHours(0, 0, 0, 0);
	var today_time = today.getTime();
	var delta = ts - today_time / 1000;
	if(delta >= 0 && delta < 86400)
	{
		return Qt.formatTime(d, "hh:mm");
	}
	else
	{
		return Qt.formatDateTime(d, "yyyy/MM/dd hh:mm");
	}
}

function MakeRedirectUrl(text)
{
	if(text.indexOf("<script>") === 0) // redirect
	{
		var spattern = /^\<script\>(\S+)\<\/script\>$/;
		var sm = text.match(spattern);
		if(sm)
		{
			var window = new Object();
			window.location = {
				href: "",
			};
			eval(sm[1]);
			return window.location.href;
		}
		else
			return false;
	}
	else
		return false;
}

var idWebAPI = {
	APPID: "wx782c26e4c19acffb",
	WX_QQ_COM: "wx%1.qq.com",

	JSLOGIN: "https://login.wx.qq.com/jslogin",
	QRCODE: "https://login.wx.qq.com/qrcode/%1",
	LOGIN: "https://login.wx.qq.com/cgi-bin/mmwebwx-bin/login",

	REDIRECT: "https://%1/cgi-bin/mmwebwx-bin/webwxnewloginpage",
	INIT: "https://%1/cgi-bin/mmwebwx-bin/webwxinit",
	CONTACT: "https://%1/cgi-bin/mmwebwx-bin/webwxgetcontact",
	CHECK: "https://webpush.%1/cgi-bin/mmwebwx-bin/synccheck",
	SYNC: "https://%1/cgi-bin/mmwebwx-bin/webwxsync",
	BATCH: "https://%1/cgi-bin/mmwebwx-bin/webwxbatchgetcontact",
	SEND: "https://%1/cgi-bin/mmwebwx-bin/webwxsendmsg",
	LOGOUT: "https://%1/cgi-bin/mmwebwx-bin/webwxlogout",

	REVOKE: "https://%1/cgi-bin/mmwebwx-bin/webwxrevokemsg",
	ICON: "https://%1/cgi-bin/mmwebwx-bin/webwxgeticon", //?seq=0&username=&skey=
	HEADIMG: "https://%1/cgi-bin/mmwebwx-bin/webwxgetheadimg", //?seq=0&username=&skey=

		// download
	MEDIA_VOICE: "https://%1/cgi-bin/mmwebwx-bin/webwxgetvoice", //?msgid=7651226812254275964&skey=@crypt_c588d4eb_2bde91f73e0c3a8b66e5e9227b3b81fb
	MEDIA_VIDEO: "https://%1/cgi-bin/mmwebwx-bin/webwxgetvideo", //?msgid=1257559779536239062&skey=%40crypt_c588d4eb_7007ee9130519c606326d371ad3a6302
	MEDIA_IMAGE: "https://%1/cgi-bin/mmwebwx-bin/webwxgetmsgimg", // ?&MsgID=9053721599568297579&skey=%40crypt_c588d4eb_f87e6a0ec51a15ccb0e4a3f227178c51&type=slave
	MEDIA_FILES: "https://file.%2/cgi-bin/mmwebwx-bin/webwxgetmedia", // ?sender=NOT_NECC&mediaid=MediaID&encryfilename=FileName&fromuser=1937268380&pass_ticket=PASS_TICKET&webwx_data_ticket=WEBWX_DATA_TICKET
	MEDIA_UPLOAD: "https://file.%1/cgi-bin/mmwebwx-bin/webwxuploadmedia", //?f=json
	VIDEO: "https://%1/cgi-bin/mmwebwx-bin/webwxsendvideomsg", //?fun=async&f=json&pass_ticket=
	IMAGE: "https://%1/cgi-bin/mmwebwx-bin/webwxsendmsgimg", //?fun=async&f=json&pass_ticket=
	FILES: "https://%1/cgi-bin/mmwebwx-bin/webwxsendappmsg", //?fun=async&f=json&pass_ticket=
	EMOJI: "https://%1/cgi-bin/mmwebwx-bin/webwxsendemoticon", //?fun=sys&lang=zh_CN&pass_ticket=




	MakeHost: function(v){
		return v !== undefined ? this.WX_QQ_COM.arg(v ? v : "") : idAPI_Domain;
	},

	MakeImgPath: function(pic){
		if(pic.indexOf("http://") !== -1 || pic.indexOf("https://") !== -1)
			return pic;
		return this.MakeAPI("https://%1" + pic);
	},

	MakeContent: function(c){
		String.prototype.replaceAll = function(s, t){
			return this.replace(new RegExp(s, "g"), t);
		}
		return c.replaceAll("&lt;", "<")
			.replaceAll("&gt;", ">");
	},

	IsGroupUname: function(uname){
		return uname.indexOf("@@") === 0;
	},

	CheckResponse: function(json){
		if(!json.BaseResponse)
			return;
		var resp = json.BaseResponse;
		if(resp.Ret != 0)
			//return "[%1]: %2".arg(resp.Ret).arg(resp.ErrMsg);
			return resp.Ret;
		else
			return 0;
	},

	MakeDeveceID: function()
	{
		var n = "";
		do
		{
			n += parseInt(Math.random() * 1e15).toString();
		}
		while(n.length < 15);

		return "e" + n.substr(0, 15);
	},

	MakeLoginUUID: function(text){
		if(!text)
			return false;
		try
		{
			var window = new Object();
			window.QRLogin = {};
			eval(text);
			if(window.QRLogin.code == 200)
				return window.QRLogin.uuid;
			else
				return false;
		}
		catch(e)
		{
			__JSON_Print(e);
			return false;
		}
	},

	MakeLoginState: function(text){
		if(!text)
			return false;
		try
		{
			var window = new Object();
			eval(text);
			return window;
		}
		catch(e)
		{
			__JSON_Print(e);
			return false;
		}
	},

	MakeLoginRedirect: function(text){
		if(!text)
			return false;
		try
		{
			var rd = MakeRedirectUrl(text);
			if(rd)
			{
				return {
					type: "URL",
					data: rd,
				};
			}
			else
			{
				var pattern = /^(\S+)/;
				var m = text.match(pattern);
				if(m)
				{
					var xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" + m[0];
					return {
						type: "XML",
						data: xml,
					};
				}
				else
					return false;
			}
		}
		catch(e)
		{
			__JSON_Print(e);
			return false;
		}
	},

	MakeHomeArticle: function(json, container){
		if(!Array.isArray(json.MPSubscribeMsgList))
			return false;
		var push = Array.isArray(container) ? "push" : "append";
		var list = json.MPSubscribeMsgList;
		for(var i in list)
		{
			var e = list[i];
			var item = {
				uname: e.UserName,
				nickname: e.NickName,
				ts: e.Time,
				articles: [],
			};
			if(e.MPArticleCount)
			{
				var sl = e.MPArticleList;
				for(var i in sl)
				{
					var se = sl[i];
					var si = {
						title: se.Title,
						preview: se.Cover,
						summary: se.Digest,
						url: se.Url,
					};
					item.articles.push(si);
				}
			}
			container[push](item);
		}
		return i;
	},

	MakeMyContact: function(json, container, limit){
		return this.MakeContact(json.MemberList, container, limit);
	},

	MakeHomeContact: function(json, container, limit){
		return this.MakeContact(json.ContactList, container, limit);
	},

	MakeUserContact: function(json, container, limit){
		return this.MakeContact(json.ContactList, container, limit);
	},

	MakeContact: function(list, container, limit){
		if(!Array.isArray(list))
			return false;
		var push = Array.isArray(container) ? "push" : "append";
		for(var i in list)
		{
			if(limit && i >= limit)
				break;

			var e = list[i];
			var item = this.MakeContactItem(e);
			container[push](item);
		}
		return i;
	},

	MakeContactItem: function(e, ret){
		var r = ret ? ret : {};

		r.uname = e.UserName;
		r.nickname = e.NickName;
		r.markname = e.RemarkName;
		r.groupname = e.DisplayName;
		r.avatar = this.MakeImgPath(e.HeadImgUrl);
		r.signature = e.Signature;
		r.sex = e.Sex;
		r.province = e.Province;
		r.city = e.City;
		r.verify = e.VerifyFlag;
		r.pinyin = e.PYQuanPin;
		r.pinyin_head = e.PYQuanPin ? e.PYQuanPin.charAt(0).toUpperCase() : "";

		if(!e.NickName && this.IsGroupUname(e.UserName))
		{
			var nn = [];
			var LIMIT = 3;
			for(var i in e.MemberList)
			{
				if(LIMIT && i >= LIMIT)
				{
					nn.push("...");
					break;
				}
				nn.push(e.MemberList[i].NickName);
			}
			r.nickname = nn.join(",");
		}

		r.chatroomid = e.EncryChatRoomId;
		r.member_list = [];
		for(var i in e.MemberList)
		{
			var ee = e.MemberList[i];
			var item = {
				uname: ee.UserName,
				nickname: ee.NickName
			};
			r.member_list.push(item);
		}

		r.msg = [];
		r.unread = 0;
		r.unsend = "";
		r.last_msg = "";

		return ret ? true : r;
	},

	MakeProfileInfo: function(json, ret){
		if(!json.User)
			return false;

		var r = ret ? ret : {};
		var u = json.User;

		r.uid = u.Uin;
		r.uname = u.UserName;
		r.nickname = u.NickName;
		r.avatar = this.MakeImgPath(u.HeadImgUrl);
		r.sex = u.Sex;
		r.signature = u.Signature;

		return ret ? true : r;
	},

	MakeCheckData: function(text){
		if(!text)
			return false;
		try
		{
			var window = new Object();
			eval(text);
			return window.synccheck;
		}
		catch(e)
		{
			__JSON_Print(e);
			return false;
		}
	},

	MakeSyncData: function(json, container, limit){
		var push = Array.isArray(container) ? "push" : "append";
		var list = json.AddMsgList;
		for(var i in list)
		{
			if(limit && i >= limit)
				break;

			var e = list[i];
			var from = e.FromUserName;
			var to = e.ToUserName;
			var group = false;
			var content = e.Content;
			if(this.IsGroupUname(from))
			{
				group = from;
				var pattern = /^(@\w+):<br\/?>(.*)$/;
				var m = content.match(pattern);
				if(m)
				{
					from = m[1];
					content = m[2];
				}
			}
			else if(this.IsGroupUname(to))
			{
				group = to;
				var pattern = /^(@\w+):<br\/?>(.*)$/;
				var m = content.match(pattern);
				if(m)
				{
					to = m[1];
					content = m[2];
				}
			}
			var item = {
				mid: e.MsgId,
				msg_type: e.MsgType,
				group: group,
				from: from,
				to: to,
				content: this.MakeContent(content),
				avatar: "",
				name: "",
				ts: e.CreateTime,
				ts_str: MakeTimestamp(e.CreateTime),

				status: 0,
				progress: 0.0,
				file: "",
				file_size: e.FileSize,
				file_name: e.FileName,
				media_id: e.MediaId,
				img_width: e.ImgWidth,
				img_height: e.ImgHeight,
				voice_length: e.VoiceLength,
				play_length: e.PlayLength,
			};
			var c = MakeSessionId(e.FromUserName, e.ToUserName);
			item.session = c.session;
			item.type = c.type;
			container[push](item);
		}
		return i;
	},

	MakeSendData: function(json, ret){
		if(!json.MsgID)
			return false;

		var r = ret ? ret : {};

		r.mid = json.MsgID;
		r.local_id = json.LocalID;
		return ret ? true : r;
	},

	MakeAPI: function(a, v){
		var h = this.MakeHost(v);
		return a.arg(h);
	},

	GetHost: function(host){
		var p = /^wx(\w*)\.qq\.com/i;
		var m = host.match(p);
		return m ? m[1] : "";
	},

	SetHost: function(host){
		idAPI_Domain = host ? host : "wx.qq.com";
	},

	MakeThumbnailUrl: function(msgid, skey, type){
		return (this.MakeAPI(this.MEDIA_IMAGE) + "?MsgID=%1&skey=%2&type=%3").arg(encodeURIComponent(msgid)).arg(encodeURIComponent(skey)).arg(type ? type : "slave");
	},

	MakeImageUrl: function(msgid, skey){
		return (this.MakeAPI(this.MEDIA_IMAGE) + "?MsgID=%1&skey=%2").arg(encodeURIComponent(msgid)).arg(encodeURIComponent(skey));
	},
	MakeVoiceUrl: function(msgid, skey){
		return (this.MakeAPI(this.MEDIA_VOICE) + "?msgid=%1&skey=%2").arg(encodeURIComponent(msgid)).arg(encodeURIComponent(skey));
	},
	MakeVideoUrl: function(msgid, skey){
		return (this.MakeAPI(this.MEDIA_VIDEO) + "?msgid=%1&skey=%2").arg(encodeURIComponent(msgid)).arg(encodeURIComponent(skey));
	},
	MakeFilesUrl: function(mediaId, passTicket, webwxDataTicket, fileName, sender, fromuser){
		return (this.MakeAPI(this.MEDIA_FILES) + "?sender=&mediaid=%1&encryfilename=%2&fromuser=&pass_ticket=%3&webwx_data_ticket=%4").arg(mediaId).arg(encodeURIComponent(fileName)).arg(encodeURIComponent(passTicket)).arg(encodeURIComponent(webwxDataTicket));
	}, // mediaid not encode for @

	MakeRevokeInfo: function(json, ret){
		if(!json)
			return false;

		var r = ret ? ret : {};

		r.introduction = json.Introduction;
		r.sys_wording = json.SysWording;

		return ret ? true : r;
	},

};

var idAPI = idWebAPI;
