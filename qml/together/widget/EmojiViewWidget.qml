import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "emoji.js" as Emoji
import "../../js/util.js" as Util

Item{
	id: root;

	property int iCellWidth: constants._iSizeXXL;
	property int iCellSpacing: 0;
	objectName: "idEmojiViewWidget";
	signal clicked(string emoji, string name);

	TabListWidget{
		id: typeview;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		height: constants._iSizeXL;
		bTabMode: true;
		bInvertedMode: true;
		cTextColor: constants._cLightColor;
		cLineColor: constants._cLightColor;
		model: [
			{
				name: qsTr("QQ face"),
				value: Emoji.QQ_FACE,
			},
			{
				name: qsTr("Emoji"),
				value: Emoji.EMOJI,
			},
		];
		onSelected: {
			Emoji.CreateModel(view.model, value);
		}
	}

	SeparaterWidget{
		id: line;
		anchors.top: typeview.bottom;
		anchors.topMargin: constants._iSpacingSmall;
		qTarget: typeview;
		color: constants._cLightColor;
		z: 1;
	}

	GridView{
		id: view;
		anchors.top: line.bottom;
		anchors.horizontalCenter: parent.horizontalCenter;
		anchors.topMargin: constants._iSpacingSmall;
		anchors.bottom: parent.bottom;
		clip: true;
		width: Math.floor(root.width / cellWidth) * cellWidth;
		cellWidth: root.iCellWidth;
		cellHeight: cellWidth;
		model: ListModel{}
		z: 1;
		delegate: Component{
			Item{
				id: delegateroot;
				width: GridView.view.cellWidth;
				height: GridView.view.cellHeight;
				clip: true;
				Item{
					anchors.centerIn: parent;
					width: model.width;
					height: model.height;
					clip: true;
					Image{
						x: -model.x;
						y: -model.y;
						source: model.src;
						cache: true;
						asynchronous: true;
					}
				}
				MouseArea{
					anchors.fill: parent;
					onClicked: {
						root.clicked(model.value, model.name);
					}
				}
			}
		}
	}

	ScrollDecorator{
		flickableItem: view;
	}

	Component.onCompleted: {
		Emoji.CreateModel(view.model);
	}
}
