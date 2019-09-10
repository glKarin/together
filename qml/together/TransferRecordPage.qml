import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: qsTr("Transfer record");
	objectName: "idTransferRecordPage";
	menus: menu;

	ContextMenu{
		id: menu;
		MenuLayout {
			MenuItem{
				text: obj.editMode === 2 ? qsTr("Done") : qsTr("Remove mode");
				enabled: view.count > 0 && (obj.editMode === 1 || obj.editMode === 2);
				onClicked: {
					obj.editMode = obj.editMode === 2 ? 1 : 2;
				}
			}
			MenuItem{
				text: obj.editMode === 3 ? qsTr("Done") : qsTr("Delete mode(include file)");
				enabled: view.count > 0 && (obj.editMode === 1 || obj.editMode === 3) && view.mode === 1;
				onClicked: {
					obj.editMode = obj.editMode === 3 ? 1 : 3;
				}
			}
			MenuItem{
				text: qsTr("Remove all");
				enabled: view.count > 0;
				onClicked: {
					obj._RemoveAll(false);
				}
			}
			MenuItem{
				text: qsTr("Delete all(include file)");
				enabled: view.count > 0 && view.mode === 1;
				onClicked: {
					obj._RemoveAll(true);
				}
			}
		}
	}

	function _Init()
	{
	}

	QtObject{
		id: obj;
		property int editMode: 1;

		function _RemoveAll(file)
		{
			controller._Query(
				qsTr("WARNING"),
				file ? qsTr("It will remove all records and local files! Are you sure?") : qsTr("It will remove all records! Are you sure?"),
				file ? qsTr("Remove") : qsTr("Remove include files"), qsTr("Cancel"),
				function(){
					view._Clear(file);
					obj.editMode = 1;
				}
			);
		}
	}

	SectionWidget{
		id: head;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		sText: root.sTitle + ": " + view.count;
		eTextAlign: constants._sAlignCenter;
	}

	TabListWidget{
		id: typeview;
		anchors.top: head.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.topMargin: constants._iSpacingSmall;
		height: constants._iSizeXL;
		bTabMode: true;
		bInvertedMode: false;
		model: [
			{
				name: qsTr("Download"),
				value: 1,
			},
			{
				name: qsTr("Upload"),
				value: 2,
			}
		];
		onClicked: {
			__ChangeView(name, value, index);
		}
	}
		//sText: root.sTitle + ": " + view.count;

	TransferListWidget{
		id: view;
		anchors.top: typeview.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.topMargin: constants._iSpacingSmall;
		mode: 1;
		showIcon: obj.editMode;
		bOpenExternally: false;
	}

	function __ChangeView(name, value, index)
	{
		view.mode = value;
		obj.editMode = 1;
	}

	Component.onCompleted: {
		var i = view.mode === 2 ? 1 : 0;
		__ChangeView(Util.ModelGetValue(typeview.model, i, "name"), Util.ModelGetValue(typeview.model, i, "value"), i);
	}
}
