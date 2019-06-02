import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;

	width: parent.width;
	height: mainlayout.height;
	clip: true;
	objectName: "idProgressWidget";
	property alias sText: title.sText;
	property alias value: progress.value;
	property alias minimumValue: progress.minimumValue;
	property alias maximumValue: progress.maximumValue;
	property alias bPressed: seekmousearea.pressed;
	property alias bEnabled: seekmousearea.enabled;
	property alias sCurText: curlabel.text;
	property alias sTotalText: totallabel.text;
	property int iMargins: 0;

	signal clicked(real value);
	signal move(real value);
	signal released(real value);

	Column{
		id: mainlayout;

		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.leftMargin: root.iMargins;
		anchors.rightMargin: root.iMargins;
		spacing: constants._iSpacingXL;

		SectionWidget{
			id: title;
			width: parent.width;
			anchors.horizontalCenter: parent.horizontalCenter;
			sText: root.sText + ": " + (bAutoLabel ? slider.value.toFixed(root.iPrecision) : sCurText);
			onClicked: root.clicked();
		}

		Column{
			width: parent.width;
			spacing: constants._iSpacingTiny;
			Row{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width - constants._iSpacingLarge * 2;
				height: constants._iSizeTiny;
				Text{
					id: curlabel;
					width: parent.width / 2;
					height: parent.height;
					horizontalAlignment: Text.AlignLeft;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants._iFontSmall;
					color: constants._cPrimaryColor;
					elide: Text.ElideRight;
					text: (progress.value * 100).toFixed(2) + "%";
				}
				Text{
					id: totallabel;
					width: parent.width / 2;
					height: parent.height;
					horizontalAlignment: Text.AlignRight;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants._iFontSmall;
					color: constants._cPrimaryColor;
					elide: Text.ElideRight;
					text: "100%";
				}
			}
			Item{
				width: parent.width;
				height: progress.height * 5;
				anchors.horizontalCenter: parent.horizontalCenter;
				clip: true;
				ProgressBar{
					id: progress;
					width: parent.width;
					anchors.centerIn: parent;
					minimumValue: 0;
					maximumValue: 100;
					clip: true;
				}
				MouseArea{
					id: seekmousearea;
					anchors.fill: parent;
					onReleased: {
						root.released(mouse.x / width);
					}
					onClicked: {
						root.clicked(mouse.x / width);
					}
					onPositionChanged: {
						if(seekmousearea.pressed) root.move(mouse.x / width);
					}
				}
			}
		}
	}
}
