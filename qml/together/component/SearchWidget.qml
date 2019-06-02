import QtQuick 1.1
import com.nokia.meego 1.1

Item {
	id: root;

	property bool bListenTextChanged: false;
	property alias sText: input.text;
	property alias bReadOnly: input.readOnly;
	property alias sPlaceholder: input.placeholderText;
	property alias bButtonVisible: btn.visible;
	property alias sActionKeyLabel: sip.actionKeyLabel;
	property alias eInputMethodHints: input.inputMethodHints;
	signal search(string text);
	signal textChanged(string text);
	signal cleared;

	objectName: "idSearchWidget";
	width: parent.width;
	height: constants._iSizeLarge;
	clip: true;

	function __Search()
	{
		var text = input.text;
		if(text !== "")
		root.search(text);
		//_MakeFocus();
	}

	function __Clear()
	{
		input.text = "";
		root.cleared();
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

	TextField{
		id: input;
		anchors.left: parent.left;
		anchors.right: btn.left;
		anchors.verticalCenter: parent.verticalCenter;
		height: parent.height;
		clip: true;
		platformStyle: TextFieldStyle{
			paddingLeft: constants._iSpacingSuper;
			paddingRight: clear.width;
		}
		platformSipAttributes: SipAttributes {
			id: sip;
			actionKeyHighlighted: actionKeyEnabled;
			actionKeyEnabled: input.text.length !== 0;
		}

		onTextChanged: {
			if(root.bListenTextChanged)
			root.textChanged(text);
		}
		Keys.onReturnPressed: {
			_MakeBlur();
			root.__Search();
		}

		ToolIcon{
			id: clear;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			width: height;
			height: parent.height;
			iconId: "toolbar-close";
			enabled: input.text !== "" && !input.readOnly;
			visible: enabled;
			onClicked: {
				root.__Clear();
			}
		}
	}

	ToolIcon{
		id: btn;
		anchors.right: parent.right;
		anchors.verticalCenter: parent.verticalCenter;
		width: height;
		height: visible ? parent.height : 0;
		iconId: "toolbar-search";
		z: 2;
		enabled: input.text !== "";
		onClicked: {
			root.__Search();
		}
	}
}
