import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "../js/main.js" as Script

BasePage {
	id: root;

	sTitle: qsTr("Browser");
	objectName: "idBrowserPage";
	eIconMode: 0;

	function _Init(url)
	{
		obj._Request(url);
	}

	QtObject{
		id: obj;
		property bool __loadImage: settings.bBrowserLoadImage;
		property bool __helper: settings.bBrowserHelper;
		property bool __dblZoom: settings.bBrowserDblZoom;

		function __BrowserUrl(url)
		{
			var i = url.indexOf("together://");
			if(i !== 0) return false;
			var value = url.substr(i + 7).toLowerCase();
			switch(value)
			{
				case "about":
				controller._ShowMessage("Together Web Browser");
				break;
				case "config":
				mainmenu.open();
				break;
				default:
				controller._ShowMessage("Invalid argument: " + value);
				return false;
			}
			return true;
		}

		function _Request(url)
		{
			if(url) input.text = url;
			var u = input.text;
			if(u == "") return;
			if(__BrowserUrl(u)) return;
			var nu = _UT.FormatUrl(u);
			if(!nu)
			{
				nu = "http://m.baidu.com/s?word=" + u;
			}
			if(input.text != nu) input.text = nu;
			webpage.url = nu;
		}
	}

	Header{
		id: header;
		color: constants._cBackgroundColor;
		ToolIcon{
			id: backward;
			anchors.left: parent.left; //back.right;
			anchors.verticalCenter: parent.verticalCenter;
			width: visible ? height : 0;
			iconId: "toolbar-tab-previous";
			enabled: webpage.bCanGoBack;
			visible: enabled;
			onClicked: {
				webpage.back();
			}
		}
		ToolIcon{
			id: forward;
			anchors.left: backward.right;
			anchors.verticalCenter: parent.verticalCenter;
			width: visible ? height : 0;
			iconId: "toolbar-tab-next";
			enabled: webpage.bCanGoForward;
			visible: enabled;
			onClicked: {
				webpage.forward();
			}
		}

		TextField{
			id: input;
			anchors.left: forward.right;
			anchors.right: menuicon.left;
			anchors.verticalCenter: parent.verticalCenter;
			z: 1;
			clip: true;
			placeholderText: qsTr("Input url or keyword");
			inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase;
			platformStyle: TextFieldStyle{
				paddingLeft: clear.width;
				paddingRight: sp.width;
			}
			platformSipAttributes: SipAttributes {
				id: sip;
				actionKeyHighlighted: actionKeyEnabled;
				actionKeyEnabled: input.text.length !== 0;
				actionKeyLabel: qsTr("OK");
			}

			Keys.onReturnPressed: {
				obj._Request();
				input.platformCloseSoftwareInputPanel();
				webpage.forceActiveFocus();
			}

			ToolIcon{
				id: clear;
				anchors.left: parent.left;
				anchors.verticalCenter: parent.verticalCenter;
				width: height;
				height: constants._iSizeLarge;
				clip: true;
				iconId: "toolbar-close";
				enabled: input.text !== "" && !input.readOnly && input.focus;
				visible: enabled;
				onClicked: {
					input.text = "";
					input.forceActiveFocus();
					input.platformOpenSoftwareInputPanel();
				}
			}
			ToolIcon{
				id: sp;
				anchors.right: parent.right;
				anchors.verticalCenter: parent.verticalCenter;
				width: height;
				height: constants._iSizeLarge;
				clip: true;
				iconId: webpage.progress != 1 ? "toolbar-stop" : "toolbar-refresh";
				onClicked: {
					if(webpage.progress != 1) webpage.stop();
					else webpage.reload();
				}
			}
		}

		ToolIcon{
			id: menuicon;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			width: height;
			iconId: "toolbar-view-menu";
			onClicked: {
				mainmenu.open();
			}
		}
	}

	ProgressBar{
		anchors.verticalCenter: header.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.leftMargin: constants._iSpacingSuper;
		anchors.rightMargin: constants._iSpacingSuper;
		z: 1;
		visible: value != 1;
		value: webpage.progress;
	}

	WebPage{
		id: webpage;
		anchors.top: header.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		dontDelegateLinks: true;
		bLoadImage: obj.__loadImage;
		bBrowserHelper: obj.__helper;
		bAllowDblZoom: obj.__dblZoom;
		onAlert: {
			controller._ShowMessage(message);
		}
		onTitleChanged: {
			root.sTitle = title;
		}
	}

	ContextMenu{
		id: mainmenu;
		MenuLayout {
			MenuItem {
				text: qsTr("Open externally");
				enabled: webpage.url != "";
				onClicked: {
					if(webpage.url != "") controller._OpenUrl(webpage.url, 1);
				}
			}
			MenuItem{
				text: qsTr("Helper");
				clip: true;
				CheckBox{
					id: browserHelper;
					anchors.verticalCenter: parent.verticalCenter;
					anchors.right: parent.right;
					checked: settings.bBrowserHelper;
					onClicked: {
						settings.bBrowserHelper = checked;
					}
				}
			}
			MenuItem{
				text: qsTr("Load image");
				clip: true;
				CheckBox{
					id: browserLoadImage;
					anchors.verticalCenter: parent.verticalCenter;
					anchors.right: parent.right;
					checked: settings.bBrowserLoadImage;
					onClicked: {
						settings.bBrowserLoadImage = checked;
					}
				}
			}
			MenuItem{
				text: qsTr("Double-click zoom");
				clip: true;
				CheckBox{
					id: browserDblZoom;
					anchors.verticalCenter: parent.verticalCenter;
					anchors.right: parent.right;
					checked: settings.bBrowserDblZoom;
					onClicked: {
						settings.bBrowserDblZoom = checked;
					}
				}
			}
			MenuItem{
				text: qsTr("Copy url");
				enabled: webpage.url != "";
				onClicked: {
					if(webpage.url != "") controller._CopyToClipboard(webpage.url);
				}
			}
			MenuItem {
				text: qsTr("Back");
				onClicked: {
					pageStack.pop();
				}
			}
		}
	}

}
