import QtQuick 1.1

Flipable{
	id: root;
	
	objectName: "idFlipableWidget";
	property bool bOpen: false;

	state: bOpen ? constants._sShowState : "";

	transform: Rotation{
		id: rotation;
		origin: Qt.vector3d(root.width / 2, root.height / 2, 0);
		axis: Qt.vector3d(0, 1, 0);
		angle: 0;
	}
	states: State{
		name: constants._sShowState;
		PropertyChanges{
			target: rotation;
			angle: 180;
		}
	}
	transitions: Transition{
		RotationAnimation{
			direction: RotationAnimation.Clockwise;
		}
	}
	
	function _Toggle(on)
	{
		if(on === undefined) bOpen = !bOpen;
		else
		{
			bOpen = on ? true : false;
		}
	}
}
