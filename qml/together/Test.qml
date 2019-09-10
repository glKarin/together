import QtQuick 1.1
import com.nokia.meego 1.1
import karin.together 1.0
import QtMultimediaKit 1.1
import QtMobility.systeminfo 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

Grid{
	id: test;
	objectName: "idTest";
	anchors.horizontalCenter: parent.horizontalCenter;
	//enabled: _UT.dev !== 0;
	columns: Math.floor(parent.width / 90);
	spacing: 10;
	Repeater{
		model: [
			{
				name: "viewer",
				value: "controller._OpenImageViewer('"
				+
				"file:///opt/together/misc/together.jpg"
				//"file:///home/user/MyDocs/Pictures/ppsh_splash_natasha.png"
				+
				"');",
				type: "diag",
			},
			{
				name: "player",
				value: "controller._OpenVideoPlayer('file:///home/user/qt/together/gd.mp4');",
				type: "diag",
			},
			{
				name: "voice",
				value: "voice._Load('file:///opt/weibomm/misc/theme_music.mp3');",
				type: "func",
			},
			{
				name: "recorder",
				value: "controller._OpenVoiceRecorder();",
				type: "diag",
			},
			{
				name: "",
			},
			{
				name: "emoji",
				value: "controller._OpenEmojiChooser();",
				type: "diag",
			},
			{
				name: "video",
				value: "controller._OpenVideoChooser();",
				type: "diag",
			},
			{
				name: "image",
				value: "controller._OpenImageChooser();",
				type: "diag",
			},
			{
				name: "file",
				value: "controller._OpenFileChooser();",
				type: "diag",
			},
			{
				name: "camera",
				value: "controller._OpenCameraPage(true);",
				type: "page",
			},
			{
				name: "transfer",
				value: "controller._OpenTransferRecordPage();",
				type: "page",
			},
			{
				name: "settings",
				value: "controller._OpenSettingPage();",
				type: "page",
			},
			{
				name: "about",
				value: "controller._OpenAboutPage();",
				type: "page",
			},
			{
				name: "check_update",
				value: "appobj._CheckUpdate(true);",
				type: "func",
			},
			{
				name: "show_update",
				value: "appobj._ShowUpdates(2014);",
				type: "func",
			},
			{
				name: "home",
				value: "test._CreateQmlObject('MainPage.qml');",
				type: "page",
			},
			{
				name: "session",
				value: "test._CreateQmlObject('SessionPage.qml');",
				type: "page",
			},
			{
				name: "user",
				value: "test._CreateQmlObject('UserPage.qml');",
				type: "page",
			},
			{
				name: "article",
				value: "test._CreateQmlObject('ArticlePage.qml');",
				type: "page",
			},
			{
				name: "profile",
				value: "test._CreateQmlObject('ProfilePage.qml');",
				type: "page",
			},
			{
				name: "login",
				value: "test._CreateQmlObject('LoginPage.qml');",
				type: "page",
			},
			{
				name: "browser",
				value: "controller._OpenUrl('www.netlizard.net', 0);",
				type: "page",
			},
			{
				name: "group_member",
				value: "controller._OpenGroupMemberDialog();",
				type: "diag",
			},
			{
				name: "reboot",
				value: "_PIPELINE.DestroyWindow(); _PIPELINE.Boot();",
				type: "func",
			},
		];
		delegate: Component{
			Rectangle{
				width: 80;
				height: width;
				color: "transparent";
				border.width: 2;
				border.color: {
					if(modelData.type === "func")
					return "red";
					else if(modelData.type === "diag")
					return "green";
					else if(modelData.type === "page")
					return "blue";
					else
					return "lightskyblue";
				}
				radius: 5;
				Text{
					anchors.fill: parent;
					horizontalAlignment: Text.AlignHCenter;
					verticalAlignment: Text.AlignVCenter;
					font.bold: true;
					font.pixelSize: 18;
					color: "black";
					textFormat: Text.PlainText;
					text: index + "\n" + modelData.name;
					wrapMode: Text.WrapAnywhere;
				}
				MouseArea{
					anchors.fill: parent;
					onClicked: {
						eval(modelData.value);
					}
				}
			}
		}
	}

	function _CreateQmlObject(src, parent)
	{
		var p = parent ? parent : pageStack.currentPage;
		var comp = Qt.createComponent(src);
		var o = null;
		if(src.lastIndexOf("Page.qml") === src.length - 8)
		o = pageStack.push(comp);
		else
		o = comp.createObject(p);
		console.log("[Qml]: _CreateQmlObject(string:%1, Item:%2) -> Item:%3".arg(src).arg(p.objectName).arg(o.objectName));
		return o;
	}

	Component.onDestruction: {
		console.log("close dev");
	}
}
