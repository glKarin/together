import QtQuick 1.1
import "../js/main.js" as Script
import "../js/util.js" as Util

ListModel{
	id: root;
	property bool __inited: false;
	objectName: "idSubscribeModel";

	function _Reset()
	{
		__inited = false;
		Util.ModelClear(root);
	}

	function _SetData(arts)
	{
		for(var i in arts)
		{
			Util.ModelPush(root, arts[i]);
		}
		__inited = true;
	}

}
