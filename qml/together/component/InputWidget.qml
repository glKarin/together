import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;

	width: parent.width;
	height: constants._iSizeXL;
	clip: true;
	objectName: "idInputWidget";

	property alias bReadOnly: input.readOnly;
	property alias sText: title.sText;
	property alias sInputText: input.text;
	property alias sActionKeyLabel: sip.actionKeyLabel;
	property alias sPlaceholder: input.placeholderText;
	property alias inputMethodHints: input.inputMethodHints;
	property alias iLabelWidth: title.width;
	property alias eInputMethodHints: input.inputMethodHints;
	property int iMargins: 0;
	signal sure(string text);
	signal textChanged(string text);
	signal cleared;

	Row{
		anchors.fill: parent;
		anchors.leftMargin: root.iMargins;
		anchors.rightMargin: root.iMargins;
		spacing: constants._iSpacingSmall;
		clip: true;
		SectionWidget{
			id: title;
			anchors.verticalCenter: parent.verticalCenter;
			width: constants._iSizeXXXL;
			onClicked: {
				if(!input.readOnly) root._MakeFocus();
			}
		}

		TextField{
			id: input;
			anchors.verticalCenter: parent.verticalCenter;
			width: parent.width - parent.spacing - title.width;
			clip: true;
			platformSipAttributes: SipAttributes{
				id: sip;
				actionKeyHighlighted: actionKeyEnabled;
				actionKeyEnabled: input.text.length !== 0;
			}
			Keys.onReturnPressed: {
				root.__Sure();
			}
			onTextChanged: {
				root.__Sure();
			}
			platformStyle: TextFieldStyle{
				paddingLeft: constants._iSizeSmall;
				paddingRight: clear.width;
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

	function __Clear()
	{
		input.text = "";
		cleared();
		_MakeFocus();
	}

	function __Sure()
	{
		sure(input.text);
		_MakeFocus();
	}

}
