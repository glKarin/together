import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

Item{
	id: root;
	property int iMargin: constants._iSpacingSmall;
	signal avatarClicked(int index, variant data);
	signal clicked(int index, variant data);
	signal doubleClicked(int index, variant data);
	signal pressAndHold(int index, variant data);
	signal linkClicked(int index, variant data, string link);
	objectName: "idSessionDelegate";
	height: childrenRect.height + 2 * iMargin;

	Row{
		anchors.top: parent.top;
		anchors.topMargin: root.iMargin;
		anchors.horizontalCenter: parent.horizontalCenter;
		width: parent.width - 2 * root.iMargin;
		height: info.height;
		spacing: constants._iSpacingSmall;
		layoutDirection: model.type == 0 ? Qt.RightToLeft : Qt.LeftToRight;
		Image{
			id: avatar;
			anchors.top: parent.top;
			height: constants._iSizeXL;
			width: height;
			fillMode: Image.PreserveAspectCrop;
			clip: true
			source: model.avatar;
			//cache: false;
			sourceSize: Qt.size(width, height);
			MouseArea{
				anchors.fill: parent;
				onClicked: {
					root.avatarClicked(index, model);
				}
			}
		}

		BubbleWidget{
			id: info;
			anchors.verticalCenter: parent.verticalCenter;
			iMaxWidth: (parent.width - parent.spacing * 2 - avatar.width * 2);
			eMode: model.type;
			sContent: model.content;
			iMinHeight: avatar.height;
			iArrowX: avatar.y + avatar.width / 2;
			onClicked: {
				root.clicked(index, model);
			}
			onDoubleClicked: {
				root.doubleClicked(index, model);
			}
			onPressAndHold: {
				root.pressAndHold(index, model);
			}
			onLinkClicked: {
				root.linkClicked(index, model, link);
			}
		}
	}

}
