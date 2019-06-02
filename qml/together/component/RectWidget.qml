import QtQuick 1.1

Rectangle{
	id: root;
	objectName: "idRectWidget";
	property real iStart: 0;
	property real iTarget: 0;
	property string sProperty;
	property int iDuration: 250;

	states: [
		State{
			name: constants._sShowState + (root.sProperty === "x" ? "" : root.sProperty);
			PropertyChanges{
				target: root;
				x: iTarget;
			}
		},
		State{
			name: constants._sHideState + (root.sProperty === "x" ? "" : root.sProperty);
			PropertyChanges{
				target: root;
				x: iStart;
			}
		},
		State{
			name: constants._sShowState + (root.sProperty === "y" ? "" : root.sProperty);
			PropertyChanges{
				target: root;
				y: iTarget;
			}
		},
		State{
			name: constants._sHideState + (root.sProperty === "y" ? "" : root.sProperty);
			PropertyChanges{
				target: root;
				y: iStart;
			}
		},
		State{
			name: constants._sShowState + (root.sProperty === "width" ? "" : root.sProperty);
			PropertyChanges{
				target: root;
				width: iTarget;
			}
		},
		State{
			name: constants._sHideState + (root.sProperty === "width" ? "" : root.sProperty);
			PropertyChanges{
				target: root;
				width: iStart;
			}
		},
		State{
			name: constants._sShowState + (root.sProperty === "height" ? "" : root.sProperty);
			PropertyChanges{
				target: root;
				height: iTarget;
			}
		},
		State{
			name: constants._sHideState + (root.sProperty === "height" ? "" : root.sProperty);
			PropertyChanges{
				target: root;
				height: iStart;
			}
		},
		State{
			name: constants._sShowState + (root.sProperty === "opacity" ? "" : root.sProperty);
			PropertyChanges{
				target: root;
				opacity: iTarget;
			}
		},
		State{
			name: constants._sHideState + (root.sProperty === "opacity" ? "" : root.sProperty);
			PropertyChanges{
				target: root;
				opacity: iStart;
			}
		}
	]

	transitions: [
		Transition{
			from: constants._sHideState;
			to: constants._sShowState;
			NumberAnimation{
				target: root;
				property: root.sProperty;
				duration: root.iDuration;
				easing.type: Easing.OutExpo;
			}
		},
		Transition{
			from: constants._sShowState;
			to: constants._sHideState;
			NumberAnimation{
				target: root;
				property: root.sProperty;
				duration: root.iDuration;
				easing.type: Easing.InExpo;
			}
		}
	]

	function _Toggle(on)
	{
		if(on === undefined)
		{
			if(state === constants._sHideState) state = constants._sShowState;
			else if(state === constants._sShowState) state = constants._sHideState;
		}
		else
		{
			state = on ? constants._sShowState : constants._sHideState;
		}
	}
}
