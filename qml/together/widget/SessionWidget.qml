import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/main.js" as Script
import "../../js/util.js" as Util

Item{
	id: root;
	property alias model: view.model;
	property alias count: view.count;
	property alias interactive: view.interactive;
	signal refresh;
	objectName: "idSessionWidget";

	function _Init()
	{
		view.positionViewAtEnd();
	}

	Text{
		anchors.fill: parent;
		horizontalAlignment: Text.AlignHCenter;
		verticalAlignment: Text.AlignVCenter;
		font.bold: true;
		font.pixelSize: constants._iFontSuper;
		elide: Text.ElideRight;
		clip: true;
		color: constants._cDisableColor;
		text: qsTr("No message");
		visible: view.count === 0;
		MouseArea{
			anchors.centerIn: parent;
			width: parent.paintedWidth;
			height: parent.paintedHeight;
			onClicked: root.refresh();
		}
	}

	ListView{
		id: view;
		anchors.fill: parent;
		clip: true;
		z: 1;
		visible: count > 0;
		model: ListModel{}
		onCountChanged: {
			positionViewAtEnd();
		}
		delegate: Component{
			SessionDelegate{
				width: ListView.view.width;
				onClicked: {
					__View(index, data);
				}
				onDoubleClicked: {
					__Include(index, data);
				}
				onAvatarClicked: {
					__Open(index, data);
				}
				onPressAndHold: {
					__Menu(index, data);
				}
				onLinkClicked: {
					__Link(index, data, link);
				}
				onReloadClicked: {
					__Reload(index, data);
				}
			}
		}

		section.property: "ts_str";
		section.delegate: SessionSectionWidget { sText: section; }
		FastScroll{
			listView: parent;
		}
	}

	ScrollDecorator{
		flickableItem: view;
	}

	function __Menu(index, data)
	{
		sessionobj._OpenMenu(data);
	}

	function __Open(index, data)
	{
		var rid = sessionmodel._GetModelValue("chatroomid");
		controller._OpenUserPage(data.from + (rid ? " " + rid : ""));
	}

	function __View(index, data)
	{
		var msgType = data.msg_type;
		var support = [3, 34, 43, 47, 49];
		if(support.indexOf(msgType) === -1)
		{
			console.log("[Qml]: unsupport message type -> " + msgType);
			return;
		}
		var file = data.file;
		if(file)
		{
			transfer._Open(file, msgType);
			return;
		}

		if(!data.local_id) // if not send by together client, download it.
		{
			var mediaId = data.media_id;
			var fileName = data.file_name;
			var mid = data.mid;
			var sessionId = data.session;

			transfer._Load(sessionId, mid, mediaId, msgType, fileName, true);
		}
	}

	function __Include(index, data)
	{
	}

	function __Link(index, data, link)
	{
		var Files = [
			"_View_image",
			"_Play_video",
			"_Play_audio",
			"_Down_files",
			"_View_emoji",

			"_View_local_image",
			"_Play_local_video",
			"_Play_local_audio",
			"_Down_local_files",
			"_View_local_emoji",
		];
		if(Files.indexOf(link) >= 0)
		__View(index, data);
		else
		controller._OpenUrl(link);
	}

	function __Reload(index, data)
	{
		if(data.local_id) // send on together client
		{
			if(data.from === globals.uname) // reupload / resend
			{
				sessionobj._ResendMsg(data.session, data.local_id, data.to, data.content, data.msg_type);
			}
		}
		else // redownload, maybe receive or send by other client
		{
			if(data.msg_type !== 1 && !data.file)
			{
				transfer._Load(data.session, data.mid);
			}
		}
	}
}
