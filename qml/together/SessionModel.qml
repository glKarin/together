import QtQuick 1.1
import "../js/main.js" as Script
import "../js/util.js" as Util

/*
 * {
	 * session: my::uname|msg::FromUserName(if is group, is group uname)
	 * uname
	 * nickname, markname, groupname
	 * chatroomid
	 * avatar
	 * signature
	 * sex
	 * province city
	 * verify
	 * pinyin, pinyin_head
	 * member_list: [
		 * uname
		 * nickname
	 * ]
	 *
	 * msg: [
		 {
			 * mid 0 - send fail
			 * msg_type: 1 - text, 3 - image, 34 - voice, 43, 62 - video, 47 - emoji, 49 - media
			 * group: if not empty, is group uname
			 * from: if in group, is member uname
			 * to: to user
			 * avatar: sender avatar
			 * name: sender name
			 * ts: timestamp
			 * ts_str: for listview section fast scroll
			 *
			 * session: my::uname|msg::FromUserName(if is group, is group uname)
			 * type: 0 send, 1 recv
			 * local_id
			 * 
			 * status: 0 - ready, 1 - loading, 2 - error
			 * progress: 0 - 1
			 * file: local file
			 * file_size: file size from response
			 * file_name: file name from response
			 * media_id: file id from response
			 * img_width:
			 * img_height:
			 * voice_length;
			 * play_length
		 }
	 ]
	 * 
	 * unread, unsend, last_msg: 
	 }
 */
ListModel{
	id: root; // session model
	property int currentIndex: -1;
	property bool __inited: false;
	property string currentSession;
	property string currentName;
	property string currentUnsend;
	property string currentUname;
	signal currentChanged(int index, string session, string name, string unsend, string uname);
	signal preChange(int index);
	objectName: "idSessionModel";

	function _MakeSessionData(msg)
	{
		var accept_msg_types = [
			1, // text
			3, // image
			34, // voice
			43, // video
			62, // micro video
			47, // emoji
			49, // media
			10002, // delete msg
			//37, // verify msg
			//42, // share card
			//10000, // system msg
			//51, // you enter a chat
		];
		var need_notify = 0;
		Util.ModelForeach(msg, function(e, i){
			if(accept_msg_types.indexOf(e.msg_type) === -1) return;
			var item = null;
			var index = -1;
			Util.ModelForeach(root, function(it, ii){
				if(it.session === e.session)
				{
					item = it;
					index = ii;
					return false;
				}
			});

			var last_msg = root.__GetLastMsg(e.content, e.msg_type);
			var is_send = e.from === globals.uname;
			if(item) // session exists on model, `index` is valid
			{
				if(e.msg_type == 10002)
				{
					var c = e.content.replace(/\s*<br\/>\s*/g, "");
					var ms = _UT.XML_Parse(c);
					if(ms)
					{
						try
						{
							var sysmsg = ms.children[0].children;
							var mid = "";
							var msg = "";
							for(var iii in sysmsg)
							{
								var sysmsg_e = sysmsg[iii];
								if(sysmsg_e.tag === "msgid")
								mid = sysmsg_e.children;
								else if(sysmsg_e.tag === "replacemsg")
								msg = sysmsg_e.children;
							}
							if(mid)
							{
								var opt = {
									status: -1,
									content: msg,
								};
								root._UpdateProgress(e.session, mid, opt);
							}
						}
						catch(ex)
						{
							console.log(ex);
						}
					}
					return;
				}

				if(e.group) // if is group
				{
					if(is_send) // sender is me
					{
						e.avatar = globals.avatar;
						e.name = globals._GetUserShownName();
						if(currentSession !== item.session)
						{
							var ur = Util.ModelGetValue(root, index, "unread");
							Util.ModelSetValue(root, index, "unread", ur + 1);
						}
						Util.ModelSetValue(root, index, "last_msg", last_msg);
						Util.ModelPush(item.msg, e);
						root._PushFront(item.session);

						if(!e.local_id && e.mid) need_notify++;
					}
					else // recv
					{
						var uname = e.from; // get member avatar

						// find in group member
						var exists = false;
						if(item.chatroomid)
						{
							Util.ModelForeach(item.member_list, function(ge){
								if(ge.uname === uname)
								{
									e.avatar = Script.GetAvatarUrl(uname, item.chatroomid);
									e.name = ge.nickname;
									if(currentSession !== item.session)
									{
										var ur = Util.ModelGetValue(root, index, "unread");
										Util.ModelSetValue(root, index, "unread", ur + 1);
									}
									Util.ModelSetValue(root, index, "last_msg", last_msg);
									Util.ModelPush(item.msg, e);
									root._PushFront(item.session);
									exists = true;
									return false;
								}
							});
						}

						if(!exists)
						{
							appobj._GetUserContact(uname, function(n){
								e.avatar = n.avatar;
								e.name = globals._GetUserShownName(n);
								if(currentSession !== item.session)
								{
									var ur = Util.ModelGetValue(root, index, "unread");
									Util.ModelSetValue(root, index, "unread", ur + 1);
								}
								Util.ModelSetValue(root, index, "last_msg", last_msg);
								Util.ModelPush(item.msg, e);
								root._PushFront(item.session);
							}, item.chatroomid);
						}

						need_notify++;
					}
				} // end group
				else // people
				{
					e.avatar = is_send ? globals.avatar : item.avatar;
					e.name = globals._GetUserShownName(is_send ? globals : item);
					if(currentSession !== item.session)
					{
						var ur = Util.ModelGetValue(root, index, "unread");
						Util.ModelSetValue(root, index, "unread", ur + 1);
					}
					Util.ModelSetValue(root, index, "last_msg", last_msg);
					Util.ModelPush(item.msg, e);
					root._PushFront(item.session);

					need_notify++;
				}
			} // end exists

			else // session is not exists, new session
			{
				if(e.msg_type == 10002)
				{
					var ms = _UT.XML_Parse(e.content);
					if(ms)
					{
						try
						{
							var sysmsg = ms.children[0];
							for(var iii in sysmsg)
							{
								var sysmsg_e = sysmsg[iii];
								if(sysmsg_e.tag === "replacemsg")
								{
									e.content = sysmsg_e.children;
									break;
								}
							}
						}
						catch(ex)
						{
							console.log(ex);
						}
					}
					e.status = -1;
				}

				if(e.group) // if is group
				{
					if(is_send) // sender is me
					{
						appobj._GetUserContact(e.group, function(g){
							g.session = e.session;
							e.avatar = globals.avatar;
							e.name = globals._GetUserShownName();
							g.msg.push(e);
							g.last_msg = last_msg;
							if(root.currentSession !== g.session) g.unread++;
							root._PushFront(g);
						});

						if(!e.local_id && e.mid) need_notify++;
					}
					else // recv
					{
						appobj._GetUserContact(e.group, function(g){
							g.session = e.session;
							g.last_msg = last_msg;
							if(root.currentSession !== g.session) g.unread++;
							var uname = e.from; // get member avatar

							// find in group member
							var exists = false;
							if(g.chatroomid)
							{
								Util.ModelForeach(g.member_list, function(ge){
									if(ge.uname === uname)
									{
										e.avatar = Script.GetAvatarUrl(uname, g.chatroomid);
										e.name = ge.nickname;
										g.msg.push(e);
										root._PushFront(g);
										exists = true;
										return false;
									}
								});
							}

							if(!exists)
							{
								appobj._GetUserContact(uname, function(n){
									e.avatar = n.avatar;
									e.name = globals._GetUserShownName(n);
									g.msg.push(e);
									root._PushFront(g);
								}, g.chatroomid);
							}
						});

						need_notify++;
					}
				} // end group
				else // people
				{
					var uname = is_send ? e.to : e.from; // get session avatar
					appobj._GetUserContact(uname, function(n){
						n.session = e.session;
						if(is_send)
						{
							e.avatar = globals.avatar;
							e.name = globals._GetUserShownName();
						}
						else
						{
							e.avatar = n.avatar;
							e.name = globals._GetUserShownName(n);
						}
						n.msg.push(e);
						n.last_msg = last_msg;
						if(root.currentSession !== e.session) n.unread++;
						root._PushFront(n);
					});

					need_notify++;
				}
			}
		});

		if(need_notify > 0)
		appobj._Notify(need_notify);
	}

	// put a new session on front
	function _AddSession(data)
	{
		if(_GetSession(data.uname)) return;
		var d = {};
		var Keys = [
			"uname", "nickname", "markname", "groupname", "avatar", "signature", "sex", "province", "city", "verify", "pinyin",
			"pinyin_head",
		];
		for(var i in Keys)
		{
			d[Keys[i]] = data[Keys[i]];
		}

		d.msg = [];
		d.unread = 0;
		d.unsend = "";
		d.last_msg = "";
		var c = Script.MakeSessionId(globals.uname, d.uname);
		d.session = c.session,
		_PushFront(d);
	}

	function _Find(s)
	{
		var m = null;
		Util.ModelForeach(root, function(e, i){
			if(e.session === s)
			{
				m = e;
				return false;
			}
		});
		return m;
	}

	// get session by uname
	function _GetSession(un)
	{
		var m = null;
		Util.ModelForeach(root, function(e, i){
			if(e.uname === un)
			{
				m = e;
				return false;
			}
		});
		if(m) return m.session;
		else return false;
		/*
		 {
			 appobj._GetUserContact(un, function(n){
				 var c = Script.MakeSessionId(globals.uname, n.uname);
				 n.session = c.session,
				 Util.ModelPush(root, n);
			 });
		 }
		 */
	}

	// set current state
	function _SyncCurrent(w)
	{
		var index = -1;
		var sess = "";
		if(typeof(w) === "number")
		{
			if(w >= 0)
			{
				index = w;
				sess = Util.ModelGetValue(root, w, "session");
			}
		}
		else
		{
			var w_is_session = w.indexOf(Script.SPLIT) !== -1;
			Util.ModelForeach(root, function(e, i){
				if((w_is_session && e.session === w)
				|| (!w_is_session && e.uname === w))
				{
					index = i;
					sess = e.session;
					return false;
				}
			});
		}

		//if(currentIndex == index) return;

		// if is current, only update index, exam. other session insert front
		if(currentSession !== sess) root.preChange(currentIndex);

		currentIndex = index;
		if(currentIndex >= 0)
		{
			var m = Util.ModelGet(root, currentIndex);
			if(m)
			{
				currentName = globals._GetUserShownName(m);
				currentSession = m.session;
				currentUnsend = m.unsend;
				currentUname = m.uname;
				root._SetModelValue("unread", 0);
			}
			else
			{
				currentIndex = -1;
				currentName = "";
				currentSession = "";
				currentUnsend = "";
				currentUname = "";
			}
		}
		else
		{
			currentName = "";
			currentSession = "";
			currentUnsend = "";
			currentUname = "";
		}
		root.currentChanged(currentIndex, currentSession, currentName, currentUnsend, currentUname);
	}

	function _Reset()
	{
		__inited = false;
		Util.ModelClear(root);
		_SyncCurrent(-1);
	}

	function _SetModelValue(name, value, index)
	{
		var i = index !== undefined ? index : currentIndex;
		Util.ModelSetValue(root, i, name, value);
	}

	function _SetData(contacts)
	{
		for(var i in contacts)
		{
			var exists = false;
			Util.ModelForeach(root, function(e){
				if(e.uname === contacts[i].uname)
				{
					root._UpdateData(contacts[i]);
					exists = true;
					return false;
				}
			});
			if(!exists)
			Util.ModelPush(root, contacts[i]);
		}
		__inited = true;
	}

	// push session to front
	function _PushFront(w)
	{
		if(typeof(w) === "object")
		{
			Util.ModelInsert(root, 0, w);
		}
		else
		{
			if(typeof(w) === "number") Util.ModelMove(root, w);
			else
			{
				var index = -1;
				Util.ModelForeach(root, function(e, i){
					if(e.session === w)
					{
						index = i;
						return false;
					}
				});
				if(index !== -1) Util.ModelMove(root, index);
			}
		}
		if(currentIndex === -1) _SyncCurrent(currentSession);
	}

	// Update msg data by local_id
	function _UpdatePreProgress(session, local_id, data)
	{
		Util.ModelForeach(root, function(item){
			if(item.session === session)
			{
				Util.ModelForeach(item.msg, function(it, ii){
					if(it.local_id === local_id)
					{
						for(var k in data)
							Util.ModelSetValue(item.msg, ii, k, data[k]);
						return false;
					}
				});
				return false; // continue
			}
		});
	}

	// Update msg data by msg_id
	function _UpdateProgress(session, mid, data)
	{
		Util.ModelForeach(root, function(item, i){
			if(item.session === session)
			{
				Util.ModelForeach(item.msg, function(it, ii){
					if(it.mid === mid)
					{
						for(var k in data)
						{
							Util.ModelSetValue(item.msg, ii, k, data[k]);
							if(k === "content")
							{
								if(ii === Util.ModelSize(item.msg) - 1) // last msg
								{
									Util.ModelSetValue(root, i, "last_msg", data["content"]);
								}
							}
						}
						return false;
					}
				});
				return false; // continue
			}
		});
	}

	function _RemoveMsg(session, mid, local_id)
	{
		Util.ModelForeach(root, function(item, i){
			if(item.session === session)
			{
				Util.ModelForeach(item.msg, function(it, ii){
					if((mid && it.mid === mid) || (local_id && it.local_id === local_id))
					{
						var is_last = (ii === Util.ModelSize(item.msg) - 1); // last msg
						Util.ModelRemove(item.msg, ii);
						if(is_last)
						{
							var ni = ii - 1;
							Util.ModelSetValue(root, i, "last_msg", ni >= 0 ? root.__GetLastMsg(Util.ModelGetValue(item.msg, ni, "content"), Util.ModelGetValue(item.msg, ni, "msg_type")) : "");
						}
						return false;
					}
				});
				return false; // continue
			}
		});
	}

	function _DeleteSession(session)
	{
		Util.ModelForeach(root, function(item, index){
			if(item.session === session)
			{
				Util.ModelRemove(root, index);
				return false; // continue
			}
		});
	}
	
	function _RemoveSession(session)
	{
		Util.ModelForeach(root, function(item, index){
			if(item.session === session)
			{
				Util.ModelClear(item.msg);
				Util.ModelSetValue(root, index, "last_msg", "");
				Util.ModelSetValue(root, index, "unread", 0);
				return false; // continue
			}
		});
	}

	function __GetLastMsg(content, msgType)
	{
		var c = "";
		switch(msgType)
		{
			case 3:
			c = qsTr("Image");
			break;
			case 34:
			c = qsTr("Voice");
			break;
			case 43:
			case 62:
			c = qsTr("Video");
			break;
			case 49:
			c = qsTr("Files");
			break;
			case 47:
			c = qsTr("Emoji");
			break;
			default:
			break;
		}
		if(c)
		return "[" + c + "]";
		else
		return content;
	}

	function _GetModelValue(name, index)
	{
		var i = index !== undefined ? index : currentIndex;
		return Util.ModelGetValue(root, i, name);
	}

	function _UpdateData(data)
	{
		var d = Array.isArray(data) ? data : [data];
		var Keys = [
			"uname", "nickname", "markname", "groupname", "avatar", "signature", "sex", "province", "city", "verify", "pinyin", "chatroomid",
			"pinyin_head",
		];

		var GroupKeys = [
			"uname",
			"nickname",
		];

		for(var i in d)
		{
			var item = d[i];
			Util.ModelForeach(root, function(e, index){
				if(e.uname === item.uname)
				{
					for(var ii in Keys)
					{
						var name = Keys[ii];
						if(e[name] !== item[name] && item[name] !== undefined)
							Util.ModelSetValue(root, index, name, item[name]);
					}
					if(Script.idAPI.IsGroupUname(e.uname))
					{
						Util.ModelClear(e.member_list);
						Util.ModelForeach(item.member_list, function(ee){
							Util.ModelPush(e.member_list, ee);
						});
					}
					return false;
				}
			});
		}
	}
}
