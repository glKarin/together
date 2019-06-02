import QtQuick 1.1
import com.nokia.meego 1.1
import "itemlist.js" as L

Item{
	id: root;
	property int eHorizontalAlignment: Text.AlignLeft;
	property variant vNu: false;
	property alias sTitle: title.sText;
	property variant aTexts: [];
	property int iPixelSize: constants._iFontLarge;
	property color cColor: constants._cPrimaryColor;
	property alias cTitleColor: title.cTextColor;
	property int iMargins: 0;
	property int iSpacing: col.spacing;
	signal linkClicked(string link);
	signal clicked;

	objectName: "idTextListWidget";
	width: parent.width;
	height: mainlayout.height;
	clip: true;

	Column {
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

		Column{
			id: col;
			width: parent.width;
			spacing: constants._iSpacingMedium;
		}
	}

	Component{
		id: textitem;
		Text{
			font.pixelSize: root.iPixelSize;
			width: col.width;
			color: root.cColor;
			wrapMode: Text.WordWrap;
			horizontalAlignment: root.eHorizontalAlignment;
			onLinkActivated: {
				root.linkClicked(link);
			}
		}
	}

	onATextsChanged: {
		__FillTextList(aTexts, vNu);
	}

	onVNuChanged: {
		__FillTextList(aTexts, vNu);
	}

	function __FillTextList(ts, n)
	{
		L.Clear();
		col.children = [];

		if(!ts) return;

		for(var i = 0; i < ts.length; i++)
		{
			var s = ts[i];
			var item = textitem.createObject(col);
			L.Push(item);
			item.text = __MakeText(s.text, n, i);
			if(s.pixelSize) item.font.pixelSize = s.pixelSize;
			if(s.color) item.color = s.color;
			if(s.horizontalAlignment) item.horizontalAlignment = s.horizontalAlignment;
			//console.log(s.text);
		}
	}

	function __MakeText(text, n, i)
	{
		var nt = typeof(n);
		var s;
		switch(nt)
		{
			case "string":
			s = n + text;
			break;
			case "number":
			s = "" + (n + i) + ", " + text;
			break;
			case "function":
			s = n() + text;
			break;
			default:
			s = n ? ("" + (i + 1) + ", " + text) : text;
			break;
		}
		return s;
	}
}
