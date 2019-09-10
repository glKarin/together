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
	signal reloadClicked(int index, variant data);
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
		AvatarWidget{
			id: avatar;
			anchors.top: parent.top;
			height: constants._iSizeXL;
			width: height;
			source: model.status >= 0 ? model.avatar : "";
			//visible: model.status >= 0;
			onClicked: {
				root.avatarClicked(index, model);
			}
		}

		BubbleWidget{
			id: info;
			anchors.verticalCenter: parent.verticalCenter;
			iMaxWidth: (parent.width - parent.spacing * 2 - avatar.width * 2 - reloadicon.width);
			eMode: model.type;
			sContent: model.content;
			iMinHeight: avatar.height;
			iArrowX: avatar.y + avatar.width / 2;
			bInteractive: model.status >= 0;
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

		Rectangle{
			id: reloadicon;
			anchors.verticalCenter: parent.verticalCenter;
			width: constants._iSizeMedium;
			height: width;
			radius: width / 2;
			visible: model.status > 0;
			color: model.status === 2 ? constants._cErrorColor : constants._cTransparent;
			//clip: true;
			smooth: true;
			ToolIcon{
				anchors.fill: parent;
				iconId: "toolbar-jump-to";
				enabled: model.status === 2;
				visible: enabled;
				onClicked: {
					root.reloadClicked(index, model);
				}
			}

			BusyIndicator{
				id: indicator;
				anchors.centerIn: parent;
				visible: running;
				running: model.status === 1;
				z: 1;
				platformStyle: BusyIndicatorStyle{
					size: "medium";
				}
				Text{
					id: progress;
					anchors.fill: indicator;
					z: 2;
					verticalAlignment: Text.AlignVCenter;
					horizontalAlignment: Text.AlignHCemter;
					font.pixelSize:constants._iFontMedium;
					color: constants._cHighlightColor;
					text: parseInt(model.progress * 100) + "%";
					visible: model.status === 1 && (model.progress > 0.0 && model.progress < 1.0);
				}
			}
		}

	}

}
