import QtQuick 1.1
import com.nokia.meego 1.1
import "itemlist.js" as L

Item{
	id: root;
	objectName: "idSelectWidget";
	width: parent.width;
	height: mainlayout.height;
	clip: true;

	property alias sText: title.sText;
	property variant aOptions: [];
	property variant vCurrentValue: null;
	property int iCurrentIndex: 0;
	property int iMargins: 0;
	signal selected(int index, variant value, bool disable);
	signal clicked;

	Column{
		id: mainlayout;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.leftMargin: root.iMargins;
		anchors.rightMargin: root.iMargins;
		spacing: constants._iSpacingXL;

		SectionWidget{
			id: title;
			width: parent.width;
			anchors.horizontalCenter: parent.horizontalCenter;
			onClicked: root.clicked();
		}

		ButtonColumn{
			id: col;
			width: parent.width;
			spacing: constants._iSpacingMedium;
			exclusive: true;
		}
	}

	Component{
		id: checkbox;
		CheckBox{
			property int index;
			property variant value;
			property bool enabled: true;

			width: col.width;
			onClicked: {
				iCurrentIndex = index;
				vCurrentValue = value;
				root.selected(index, value, false);
			}
			MouseArea{
				anchors.fill: parent;
				enabled: !parent.enabled;
				onClicked: {
					root.selected(index, value, true);
					mouse.accepted = true;
				}
			}
		}
	}

	onAOptionsChanged: {
		L.Clear();
		col.children = [];

		for(var k in aOptions)
		{
			var s = aOptions[k];
			var item = checkbox.createObject(col);
			L.Push(item);
			item.index = k;
			item.text = s.name;
			item.value = s.value;
			if(s.enabled !== undefined)
				item.enabled = s.enabled;
			//console.log(s.text, s.value);
			/*
			item.clicked.connect(function(){
				root.selected(value);
			});
			*/
		}
		if(vCurrentValue !== null && vCurrentValue !== undefined) __SetCurrentChecked(vCurrentValue);
		else __SetCurrentCheckedByIndex(iCurrentIndex);
	}

	onVCurrentValueChanged: {
		__SetCurrentChecked(vCurrentValue);
	}

	onICurrentIndexChanged: {
		__SetCurrentCheckedByIndex(iCurrentIndex);
	}

	function __SetCurrentChecked(v)
	{
		var items = col.children;
		for(var i = 0; i < items.length; i++)
		{
			items[i].checked = false;
		}
		for(var i = 0; i < items.length; i++)
		{
			if(items[i].value == v)
			{
				items[i].checked = true;
				break;
			}
		}
	}

	function __SetCurrentCheckedByIndex(v)
	{
		var items = col.children;
		for(var i = 0; i < items.length; i++)
		{
			items[i].checked = false;
		}
		if(v >= items.length) return;
		items[v].checked = true;
	}
}
