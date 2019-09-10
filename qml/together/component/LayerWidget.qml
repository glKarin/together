import QtQuick 1.1

Item{
	id: root;
	default property alias content: contentitem.children;
	property bool bAutoDestroy: false;
	property bool bAutoOpen: false;
	property alias cBackgroundColor: bg.color;
	property alias cForegroundColor: contentitem.color;
	property int eContentSizePolicy: 0;
	property alias contentItem: contentitem;

	signal opened();
	signal closed();

	objectName: "idLayerWidget";
	z: 30;

	anchors.fill: parent;
	visible: opacity === 1.0;
	state: constants._sHideState;
	states: [
		State{
			name: constants._sShowState;
			PropertyChanges{
				target: root;
				opacity: 1.0;
			}
		},
		State{
			name: constants._sHideState;
			PropertyChanges{
				target: root;
				opacity: 0.0;
			}
		}
	]

	transitions: [
		Transition{
			from: constants._sHideState;
			to: constants._sShowState;
			NumberAnimation{
				target: root;
				property: "opacity";
				duration: 240;
				easing.type: Easing.OutExpo;
			}
		},
		Transition{
			from: constants._sShowState;
			to: constants._sHideState;
			NumberAnimation{
				target: root;
				property: "opacity";
				duration: 240;
				easing.type: Easing.InExpo;
			}
		}
	]

	Rectangle{
		id: bg;
		anchors.fill: parent;
		color: constants._cDarkColor;
		opacity: 0.6;
		MouseArea{
			anchors.fill: parent;
			onClicked: {
				root._Close();
			}
		}
	}

	Rectangle{
		id: contentitem;
		anchors.centerIn: parent;
		width: root.eContentSizePolicy === 1 ? childrenRect.width : (root.eContentSizePolicy === 2 ? parent.width : Math.min(parent.width, parent.height));
		height: root.eContentSizePolicy === 1 ? childrenRect.height : (root.eContentSizePolicy === 2 ? parent.height : width);
		z: 1;
		color: constants._cDarkColor;
	}

	function _Open(path)
	{
		root.state = constants._sShowState;
	}

	function _Close()
	{
		root.state = constants._sHideState;
	}

	onStateChanged: {
		if(state === constants._sHideState)
		{
			root.closed();
			if(!root.visible)
			{
				root.destroy(250);
			}
		}
		else if(state === constants._sShowState)
		root.opened();
	}

	Component.onCompleted: {
		if(bAutoOpen) _Open();
	}

}
