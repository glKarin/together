import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

Item{
	id: root;
	property int iSubItemHeight: constants._iSizeXXXL;
	signal headerClicked(int index, string uname);
	signal clicked(int index, variant data);
	signal imageClicked(int index, variant data);
	signal longPressed(int index, variant data);
	objectName: "idSubscribeListDelegate";

	height: childrenRect.height;

	Column{
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.leftMargin: constants._iSpacingMedium;
		anchors.rightMargin: constants._iSpacingMedium;
		spacing: constants._iSpacingMedium;

		SectionWidget{
			anchors.horizontalCenter: parent.horizontalCenter;
			width: parent.width;
			sText: model.nickname;
			onClicked: {
				root.headerClicked(index, model.uname);
			}
		}

		Column{
			id: sublayout;
			anchors.horizontalCenter: parent.horizontalCenter;
			width: parent.width - constants._iSpacingMedium * 2;
			Repeater{
				model: articles;
				delegate: Component{
					Item{
						width: sublayout.width;
						height: root.iSubItemHeight;
						clip: true;

						MouseArea{
							anchors.fill: parent;
							onClicked: {
								root.clicked(index, model);
							}
							onPressAndHold: {
								root.longPressed(index, model);
							}
						}

						Text{
							id: info;
							anchors.left: parent.left;
							anchors.leftMargin: constants._iSpacingLarge;
							anchors.right: preview.left;
							anchors.rightMargin: constants._iSpacingMedium;
							anchors.verticalCenter: parent.verticalCenter;
							height: preview.height;
							text: model.title;
							font.pixelSize: constants._iFontXL;
							elide: Text.ElideRight;
							color: constants._cPrimaryColor;
							verticalAlignment: Text.AlignVCenter;
							maximumLineCount: 2;
							wrapMode: Text.WrapAnywhere;
						}

						Image{
							id: preview;
							anchors.right: parent.right;
							anchors.rightMargin: constants._iSpacingLarge;
							anchors.verticalCenter: parent.verticalCenter;
							height: parent.height - constants._iSpacingLarge * 2;
							width: height;
							fillMode: Image.PreserveAspectCrop;
							smooth: true;
							clip: true
							source: model.preview;
							cache: false;
							sourceSize: Qt.size(width, height);
							MouseArea{
								anchors.fill: parent;
								onClicked: {
									root.imageClicked(index, model);
								}
							}
						}

						SeparaterWidget{
							anchors.bottom: parent.bottom;
							anchors.bottomMargin: constants._iSpacingMicro;
							qTarget: info;
							z: 1;
						}
					}
				}
			}
		}
	}
}
