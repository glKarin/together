import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"

Item{
	id: root;

	objectName: "idUserViewWidget";

	property string uid;
	property string nickname;
	property string uname;
	property int sex;
	property string avatar;
	property string signature;
	property string province;
	property string city;

	property string markname;
	property string groupname;
	property string verify;
	property string pinyin;
	property string pinyin_head;

	default property alias extras: view.children;

	signal avatarClicked;
	signal previewClicked;

	function _SetInfo(data)
	{
		var Keys = [
			"uname", "nickname", "markname", "groupname", "avatar", "signature", "sex", "province", "city", "verify", "pinyin",
			"pinyin_head",
		];
		for(var i in Keys)
		{
			var name = Keys[i];
			if(data[name] !== undefined) root[name] = data[name];
		}
	}

	Image{
		id: preview;
		property int initHeight: constants._iSizeTooBig;
		property int theight: constants._iSizeXXXL;
		anchors.top: parent.top;
		anchors.horizontalCenter: parent.horizontalCenter;
		height: Math.max(initHeight, initHeight - descview.contentY);
		width: parent.width * (height / initHeight);
		fillMode: Image.PreserveAspectCrop;
		smooth: true;
		clip: true;
		cache: false;
		z: 1;
		source: root.avatar;
		MouseArea{
			anchors.fill: parent;
			onClicked: {
				root.previewClicked();
			}
		}
	}

	Rectangle{
		id: avatarrect;
		anchors.verticalCenter: preview.bottom;
		anchors.left: parent.left;
		anchors.leftMargin: constants._iSpacingBig;
		width: constants._iSizeXXL;
		height: width;
		border.width: 4;
		border.color: constants._cThemeColor;
		color: constants._cTransparent;
		z: 2;
		Image{
			id: avatar;
			anchors.centerIn: parent;
			height: parent.height - parent.border.width;
			width: height;
			cache: false;
			sourceSize.width: width;
			sourceSize.height: height;
			source: root.avatar;
			smooth: true;
		}
		MouseArea{
			anchors.fill: parent;
			onClicked: {
				root.avatarClicked();
			}
		}
	}

	Text{
		id: uname;
		anchors.top: preview.bottom;
		anchors.bottom: avatarrect.bottom;
		anchors.left: avatarrect.right;
		anchors.right: parent.right;
		anchors.leftMargin: constants._iSpacingBig;
		verticalAlignment: Text.AlignVCenter;
		font.pixelSize: constants._iFontXXL;
		elide: Text.ElideRight;
		clip: true;
		font.bold: true;
		color: constants._cPrimaryColor;
		text: root.nickname + (root.markname ? "(%1)".arg(root.markname) : "");
	}

	Flickable{
		id: descview;
		anchors.top: preview.top;
		anchors.topMargin: preview.initHeight + avatarrect.height / 2;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		contentWidth: width;
		contentHeight: desclayout.height;
		clip: true;

		Column{
			id: desclayout;
			width: parent.width;
			Column{
				id: infocol;
				property int theight: childrenRect.height;
				width: parent.width;
				anchors.horizontalCenter: parent.horizontalCenter;
				spacing: constants._iSpacingSmall;
				clip: true;

				Row{
					id: infolayout;
					anchors.horizontalCenter: parent.horizontalCenter;
					width: parent.width - constants._iSpacingXXL * 2;
					height: constants._iSizeLarge;
					spacing: constants._iSpacingXXL;
					clip: true;
					Repeater{
						id: infolist;
						model: [
							{
								name: "",
								value: globals._GetSexName(root.sex),
							},
							{
								name: root.province,
								value: "",
							},
							{
								name: "",
								value: root.city,
							},
						];
						delegate: Component{
							Row{
								height: infolayout.height;
								clip: true;
								spacing: constants._iSpacingMedium;
								Text{
									height: parent.height;
									verticalAlignment: Text.AlignVCenter;
									font.pixelSize: constants._iFontLarge;
									elide: Text.ElideRight;
									color: constants._cPrimaryColor;
									text: modelData.name;
								}
								Text{
									height: parent.height;
									verticalAlignment: Text.AlignVCenter;
									font.pixelSize: constants._iFontLarge;
									elide: Text.ElideRight;
									color: constants._cSecondaryColor;
									text: modelData.value;
								}
							}
						}
					}
				}

				Text{
					id: sign;
					anchors.horizontalCenter: parent.horizontalCenter;
					width: parent.width - constants._iSpacingXXL * 2;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants._iFontLarge;
					wrapMode: Text.WordWrap;
					clip: true;
					color: constants._cSecondaryColor;
					text: root.signature;
				}
			}

			Column{
				id: view;
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width - constants._iSpacingXXL * 2;
				clip: true;
			}
		}
	}
}
