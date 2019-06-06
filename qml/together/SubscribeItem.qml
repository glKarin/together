import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

Item{
	id: root;

	property bool _inited: false;
	property int _index: 0;
	objectName: "idSubscribeItem";

	function _Init()
	{
		if(!_inited) obj._GetSubscribe();
	}

	QtObject{
		id: obj;

		function _GetSubscribe()
		{
			if(!globals._IsValid()) return;

			root._inited = false;
			bBusy = true;

			view.model = subscribemodel;

			root._inited = true;
			bBusy = false;
		}
	}

	SubscribeListWidget{
		id: view;
		anchors.fill: parent;
		onRefresh: {
			obj._GetSubscribe();
		}
		onViewitem: {
			controller._OpenArticlePage(data);
		}
	}
}
