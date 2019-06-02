import QtQuick 1.1

Rectangle {
    id: root;

	objectName: "idHeaderWidget";
    property alias sText: title.text;
    property alias cTextColor: title.color;
    property alias iTextSize: title.font.pixelSize;
    property alias bMouseEnabled: mousearea.enabled;
		property int iTextMargin: 0;
    signal clicked(variant mouse);

    anchors.top: parent.top;
    anchors.left: parent.left;
    anchors.right: parent.right;
    width: parent.width;
    height: constants._iHeaderHeight;
    z: constants._iHeaderZ;

    color: constants._cGlobalColor;
    clip: true;

    Text{
        id: title;
				anchors.leftMargin: root.iTextMargin;
				anchors.rightMargin: root.iTextMargin;
        anchors.fill: parent;
        z: 1;
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
        maximumLineCount: 2;
        font.pixelSize: constants._iFontXL;
        elide: Text.ElideRight;
        font.bold: true;
        clip: true;
        color: constants._cHeaderTitleColor;
    }

    MouseArea{
        id: mousearea;
        anchors.fill: parent;
        onClicked: root.clicked(mouse);
    }
}
