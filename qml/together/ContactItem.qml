import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

Item{
	id: root;

	property bool _inited: false;
	property int _index: 1;
	objectName: "idContactItem";

	function _Init()
	{
		if(!_inited) obj._GetMyContact();
	}

	QtObject{
		id: obj;

		function _GetMyContact()
		{
			if(!globals._IsValid()) return;

			root._inited = false;
			bBusy = true;
			Util.ModelClear(view.model);
			var s = function(data){
				root._inited = true;
				bBusy = false;
			};
			var f = function(err){
				controller._ShowMessage(err);
				root._inited = false;
				bBusy = false;
			};
			var d = {
				contactModel: view.model,
			};

			Script.GetMyContact(d, s, f);
		}
	}

	ContactListWidget{
		id: view;
		anchors.fill: parent;
		onRefresh: {
			obj._GetMyContact();
		}
	}
}
