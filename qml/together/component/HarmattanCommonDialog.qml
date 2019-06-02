import QtQuick 1.1
import com.nokia.meego 1.1

Dialog {
	id: genericDialog

	objectName: "idHarmattanCommonDialog";
	property string titleText: "";
	property bool bAutoDestroy: true;
	property alias tools: btns.children;

	property int __compUsed: header.height + footer.height + constants._iSpacingMedium * 2;
	property int __contentHeight: Math.max(visualParent ? visualParent.height - __compUsed : (pageStack.currentPage ? pageStack.currentPage.height - __compUsed : 240), 0);
	property int __maxContentHeight : visualParent
	? visualParent.height * 0.87
	- root.platformStyle.titleBarHeight - root.platformStyle.contentSpacing - 50
	: root.parent
	? root.parent.height * 0.87
	- root.platformStyle.titleBarHeight - root.platformStyle.contentSpacing - 50
	: 350;

	property Style platformStyle: SelectionDialogStyle {}

	//Deprecated, TODO Remove this on w13
	property alias style: genericDialog.platformStyle

	//private
	property int __buttonTopMargin: 38
	property int __buttonsColumnSpacing: 16
	property bool __drawFooterLine: false

	property bool __isClosing: false;
	onStatusChanged: {
		if(genericDialog.bAutoDestroy)
		{
			if (status == DialogStatus.Closing){
				__isClosing = true;
			} else if (status == DialogStatus.Closed && __isClosing){
				genericDialog.destroy(250);
			}
		}
	}

	title: Item {
		id: header
		height: genericDialog.platformStyle.titleBarHeight

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.bottom: parent.bottom

		Item {
			id: labelField

			anchors.fill:  parent

			Item {
				id: labelWrapper
				anchors.left: labelField.left
				anchors.right: closeButton.left

				anchors.bottom:  parent.bottom
				anchors.bottomMargin: genericDialog.platformStyle.titleBarLineMargin

				//anchors.verticalCenter: labelField.verticalCenter

				height: titleLabel.height

				Label {
					id: titleLabel
					x: genericDialog.platformStyle.titleBarIndent
					width: parent.width - closeButton.width
					//anchors.baseline:  parent.bottom
					font: genericDialog.platformStyle.titleBarFont
					color: genericDialog.platformStyle.commonLabelColor
					elide: genericDialog.platformStyle.titleElideMode
					text: genericDialog.titleText
				}

			}

			Image {
				id: closeButton
				anchors.bottom:  parent.bottom
				anchors.bottomMargin: genericDialog.platformStyle.titleBarLineMargin-6
				//anchors.verticalCenter: labelField.verticalCenter
				anchors.right: labelField.right

				opacity: closeButtonArea.pressed ? 0.5 : 1.0

				source: "image://theme/icon-m-common-dialog-close"

				MouseArea {
					id: closeButtonArea
					anchors.fill: parent
					onClicked:  {genericDialog.reject();}
				}

			}

		}

		Rectangle {
			id: headerLine

			anchors.left: parent.left
			anchors.right: parent.right

			anchors.bottom:  header.bottom

			height: 1

			color: "#4D4D4D"
		}

	}

	content: Item { id: contentField; }

	buttons: Item {
		id: footer

		width: parent.width
		height: childrenRect.height

		//hack to make sure, we're evaluating the correct height
		Item {
			id: lineWrapper
			width: parent.width
			height: childrenRect.height
			y: 10

			Rectangle {
				id: footerLine

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				height: genericDialog.__drawFooterLine && btns.children.length > 0 ? 1 : 0

				color: "#4D4D4D"
			}
		}

		Item {
			id: btns;
			anchors.top: lineWrapper.bottom;
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.topMargin: __buttonTopMargin
			//spacing: __buttonsColumnSpacing

			width: childrenRect.width;
			height: childrenRect.height;
			clip: true;
		}

		//ugly hack to assure, that we're always evaluating the correct height
		Item {id: dummy; anchors.fill:  parent}

	}

}

