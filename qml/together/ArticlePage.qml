import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: webpage.title || obj.title || qsTr("Article");
	objectName: "idArticlePage";
	menus: subscribe;

	function _Init(data)
	{
		obj._View(data);
	}

	QtObject{
		id: obj;
		property string title;
		property string url;
		property bool __loadImage: settings.bBrowserLoadImage;
		property bool __helper: settings.bBrowserHelper;

		function _View(data)
		{
			if(data)
			{
				title = data.title;
				url = data.url;
			}
			if(url == "") return;

			webpage.url = url;
		}
	}

	SectionWidget{
		id: header;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		sText: root.sTitle;
		eTextAlign: constants._sAlignCenter;
		onClicked: {
			obj._View();
		}
	}

	WebPage{
		id: webpage;
		anchors.top: header.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		dontDelegateLinks: false;
		bLoadImage: obj.__loadImage;
		bBrowserHelper: obj.__helper;
		bAllowDblZoom: false;
		onAlert: {
			console.log(message);
		}
		onProgressChanged: {
			root.bBusy = webpage.progress !== 1;
		}
	}

	SubscribeMenuWidget{
		id: subscribe;
		anchors.fill: parent;
		function open()
		{
			_Toggle(true);
		}
		onViewitem: {
			_Toggle(false);
			obj._View(data);
		}
	}
}
