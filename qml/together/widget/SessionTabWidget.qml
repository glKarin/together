import QtQuick 1.1
import com.nokia.meego 1.1
import "../component/itemlist.js" as L
import "../../js/main.js" as Script
import "../../js/util.js" as Util

TabGroup{
	id: root;

	objectName: "idSessionTabWidget";

	function _SetCurrentSession(w)
	{
		var n = w;
		if(typeof(w) === "number")
		{
			n = Util.ModelGetValue(sessionmodel, w, "session");
		}

		var session = null;
		L.Foreach(function(e, i){
			if(e.session === n)
			{
				session = e;
				return false;
			}
		});

		if(session)
		{
			root.currentTab = session;
		}
		else
		{
			var m =	sessionmodel._Find(n);
			if(m)
			{
				var prop = {
					session: m.session,
					model: m.msg,
				};
				var obj = sessioncomp.createObject(root, prop);
				L.Push(obj);
				root.currentTab = obj;
			}
		}
	}

	function _CloseSession(w)
	{
		if(L.Count() === 0) return;

		var n = w;
		if(w === undefined)
		{
			n = currentTab ? currentTab.session : "";
		}
		else if(typeof(w) === "number")
		{
			n = Util.ModelGetValue(sessionmodel, w, "session");
		}
		if(!n) return;

		var index = -1;
		L.Foreach(function(e, i){
			if(e.session === n)
			{
				index = i;
				return false;
			}
		});
		if(index !== -1)
		{
			var next = (index > 0) ? index - 1 : (L.Count() > 1 ? 0 : -1);
			if(next >= 0)
			{
				var session = L.Get(next);
				root.currentTab = session;
			}
			else root.currentTab = null;
			L.Pop(index);
		}
	}

	Component{
		id: sessioncomp;
		SessionWidget{
			id: view;
			property string session;
			anchors.fill: parent;
		}
	}
}
