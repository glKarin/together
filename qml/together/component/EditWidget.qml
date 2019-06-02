import QtQuick 1.1
import com.nokia.meego 1.1

Item {
	id: root;

	property bool bListenTextChanged: false;
	property alias sText: input.text;
	property alias bReadOnly: input.readOnly;
	property alias sPlaceholder: input.placeholderText;
	property alias eInputMethodHints: input.inputMethodHints;
	signal sure(string text);
	signal textChanged(string text);
	signal cleared;

	objectName: "idEditWidget";
	width: parent.width;
	height: childrenRect.height;
	clip: true;

	function __Sure()
	{
		var text = input.text;
		if(text !== "")
		root.sure(text);
		//_MakeFocus();
	}

	function _Clear()
	{
		input.text = "";
		input.originalHeight = 0;
		root.cleared();
		_MakeFocus();
	}
	function _Select()
	{
		input.selectAll();
		_MakeFocus();
	}

	function _Copy() {
		input.selectAll();
		input.copy();
		_MakeFocus();
	}

	function _Paste() {
		input.paste();
		_MakeFocus();
	}

	function _Cut() {
		input.selectAll();
		input.cut();
		_MakeFocus();
	}


	function _MakeFocus()
	{
		input.forceActiveFocus();
		input.platformOpenSoftwareInputPanel();
	}

	function _MakeBlur()
	{
		input.platformCloseSoftwareInputPanel();
	}

	TextArea{
		id: input;
		property alias originalHeight: input.__originalHeight;
		anchors.left: parent.left;
		anchors.right: btn.left;
		anchors.top: parent.top;

		onTextChanged: {
			if(root.bListenTextChanged)
			root.textChanged(text);
		}
	}

	ToolIcon{
		id: btn;
		anchors.right: parent.right;
		anchors.verticalCenter: input.verticalCenter;
		width: height;
		iconId: "toolbar-mediacontrol-play";
		z: 2;
		enabled: input.text !== "";
		onClicked: {
			root.__Sure();
		}
	}
}
