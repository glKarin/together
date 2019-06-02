import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;

	width: parent.width;
	height: mainlayout.height;
	clip: true;
	objectName: "idSliderWidget";
	property string sText;
	property string sMinText: "";
	property string sMaxText: "";
	property string sCurText: "";
	property alias minimumValue: slider.minimumValue;
	property alias maximumValue: slider.maximumValue;
	property alias stepSize: slider.stepSize;
	property alias value: slider.value;
	property bool bInverted: false;
	property int iPrecision: 0;
	property bool bAutoLabel: true;
	property alias pressed: slider.pressed;
	property int iMargins: 0;

	signal move(real v);
	signal clicked;

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
			Row{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width - constants._iSpacingLarge * 2;
				height: constants._iSizeTiny;
				Text{
					id: minlabel;
					width: parent.width / 2;
					height: parent.height;
					horizontalAlignment: Text.AlignLeft;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants._iFontSmall;
					color: constants._cPrimaryColor;
					elide: Text.ElideRight;
					text: root.bAutoLabel ? slider.minimumValue : root.sMinText;
				}
				Text{
					id: maxlabel;
					width: parent.width / 2;
					height: parent.height;
					horizontalAlignment: Text.AlignRight;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants._iFontSmall;
					color: constants._cPrimaryColor;
					elide: Text.ElideRight;
					text: root.bAutoLabel ? slider.maximumValue : root.sMaxText;
				}
			}
			Slider{
				id: slider;
				width: parent.width;
				anchors.horizontalCenter: parent.horizontalCenter;
				minimumValue: 0;
				maximumValue: 100;
				stepSize: 1;
				value: 1;
				valueIndicatorText: value.toString();
				onValueChanged: {
					if(pressed) root.move(value);
				}
			}
		}
	}
}
