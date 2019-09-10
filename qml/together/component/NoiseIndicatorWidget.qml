import QtQuick 1.1

Item{
	id: root;
	property int iCount: 5;
	property real fMinWidthPercent: 0.3;
	property color cColor: constants._cLightColor;
	property int eHorizontalAlignment: 1;
	property int iLevelHeight: constants._iSizeTiny;
	property int iLevelSpacing: constants._iSpacingLarge;
	property color cMaskColor: constants._cDarkColor;
	property real fProgress: 0.0;
	property real iUpdateInterval: 180;
	property int eUpdateMode: 0;

	property real __updateStep: 0.1;

	objectName: "idNoiseIndicatorWidget";
	width: constants._iSizeXL;
	height: constants._iSizeBig;
	clip: true;

	onEUpdateModeChanged: {
		root.fProgress = 0.0;
	}

	Item{
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.verticalCenter: parent.verticalCenter;
		height: col.height;
		z: 1;

		Item{
			id: mask;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			height: col.height * root.fProgress;
			clip: true;
			NumberAnimation on height{
				duration: root.iUpdateInterval;
			}

			Column{
				id: col;
				anchors.bottom: parent.bottom;
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width;
				spacing: root.iLevelSpacing;
				Repeater{
					model: root.iCount;
					delegate: Component{
						Rectangle{
							anchors.horizontalCenter: root.eHorizontalAlignment === 0 ? parent.horizontalCenter : undefined;
							anchors.left: root.eHorizontalAlignment === 1 ? parent.left : undefined;
							anchors.right: root.eHorizontalAlignment === 2 ? parent.right : undefined;
							height: root.iLevelHeight;
							width: root.__CaleRectWidth(index);
							color: root.cColor;
						}
					}
				}
			}
		}
	}

	Timer{
		running: root.eUpdateMode !== 0;
		repeat: true;
		interval: root.iUpdateInterval;
		onTriggered: {
			if(root.eUpdateMode === 1)
			{
				root.fProgress += 0.1;
				if(root.fProgress > 1.0)
				root.fProgress = 0.0;
			}
			else if(root.eUpdateMode === 2)
			{
				if(root.fProgress > 1.0)
				root.__updateStep = root.__updateStep > 0 ? -root.__updateStep : root.__updateStep;
				else if(root.fProgress < 0.0)
				root.__updateStep = root.__updateStep < 0 ? -root.__updateStep : root.__updateStep;
				root.fProgress += root.__updateStep;
			}
			else if(root.eUpdateMode === 3)
			root.fProgress = Math.random()
		}
	}

	function __CaleRectWidth(index)
	{
		return (col.width * root.fMinWidthPercent) + (col.width * (1 - root.fMinWidthPercent)) * ((root.iCount - index) / root.iCount)
	}
}
