import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;
	width: parent.width;
	height: constants._iSizeXL;
	clip: true;
	objectName: "idSwitchWidget";

	property alias sText: title.sText;
	property alias checked: switcher.checked;
	property bool enabled: true;
	property int iMargins: 0;
	signal clicked;

	Row{
		anchors.fill: parent;
		anchors.leftMargin: root.iMargins;
		anchors.rightMargin: root.iMargins;
		spacing: constants._iSpacingSmall;
		SectionWidget{
			id: title;
			anchors.verticalCenter: parent.verticalCenter;
			width: parent.width - switcher.width - parent.spacing;
			onClicked: root.clicked();
		}
		Switch{
			id: switcher;
			anchors.verticalCenter: parent.verticalCenter;
			// checked: 
			// onCheckedChanged:{ }
			MouseArea{
				anchors.fill: parent;
				enabled: !root.enabled;
			}
		}
	}
}
