import QtQuick 1.1
import "../js/main.js" as Script
import "../js/util.js" as Util

/*
 * {
	 * session: my::uname|msg::FromUserName(if is group, is group uname)
	 * uname
	 * nickname, markname, groupname
	 * avatar
	 * signature
	 * sex
	 * province city
	 * verify
	 * pinyin, pinyin_head
	 *
	 * msg: [
		 {
			 * mid
			 * msg_type
			 * group: if not empty, is group uname
			 * from: if in group, is member uname
			 * to: UNUSED
			 * avatar: sender avatar
			 * name: sender name
			 * ts: timestamp
			 * ts_str: for listview section fast scroll
			 *
			 * session: my::uname|msg::FromUserName(if is group, is group uname)
			 * type: 0 send, 1 recv
		 }
	 ]
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
		Util.ModelForeach(msg, function(e, i){
			if(e.msg_type != 1) return;
			// 3 image
			// 34 voice
			// 43 video
			// 62 micro video
			// 47 emoti
			// 49 media
			// 37 verify msg
			// 42 share card
			// 10000 system msg
			// 10002 delete msg
			// 51 you enter a chat
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

			var is_send = e.from === globals.uname;
			if(item) // session exists on model, `index` is valid
			{
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
						Util.ModelSetValue(root, index, "last_msg", e.content);
						Util.ModelPush(item.msg, e);
						root._PushFront(item.session);
					}
					else // recv
					{
						var uname = e.from; // get member avatar
						appobj._GetUserContact(uname, function(n){
							e.avatar = n.avatar;
							e.name = globals._GetUserShownName(n);
							if(currentSession !== item.session)
							{
								var ur = Util.ModelGetValue(root, index, "unread");
								Util.ModelSetValue(root, index, "unread", ur + 1);
							}
							Util.ModelSetValue(root, index, "last_msg", e.content);
							Util.ModelPush(item.msg, e);
							root._PushFront(item.session);
						});
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
					Util.ModelSetValue(root, index, "last_msg", e.content);
					Util.ModelPush(item.msg, e);
					root._PushFront(item.session);
				}
			} // end exists

			else // session is not exists, new session
			{
				if(e.group) // if is group
				{
					if(is_send) // sender is me
					{
						appobj._GetUserContact(e.group, function(g){
							g.session = e.session;
							e.avatar = globals.avatar;
							e.name = globals._GetUserShownName();
							g.msg.push(e);
							g.last_msg = e.content;
							if(root.currentSession !== g.session) g.unread++;
							root._PushFront(g);
						});
					}
					else // recv
					{
						appobj._GetUserContact(e.group, function(g){
							g.session = e.session;
							g.last_msg = e.content;
							if(root.currentSession !== g.session) g.unread++;
							var uname = e.from; // get member avatar
							appobj._GetUserContact(uname, function(n){
								e.avatar = n.avatar;
								e.name = globals._GetUserShownName(n);
								g.msg.push(e);
								root._PushFront(g);
							});
						});
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
						n.last_msg = e.content;
						if(root.currentSession !== e.session) n.unread++;
						root._PushFront(n);
					});
				}
			}
		});
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
		var m = Util.ModelSetValue(root, i, name, value);
	}

	function _SetData(contacts)
	{
		for(var i in contacts)
		{
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
}
