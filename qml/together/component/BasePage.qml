import QtQuick 1.1
import com.nokia.meego 1.1

Page {
	id: root;

	property bool bBusy: false;
	property bool bFull: false;
	property bool bLock: false;
	property bool bPopI: false;
	property string sTitle;
	property int eIconMode: 1;
	property Item menus: null;
	// 1 back
	// 2 menu
	signal iconClicked(int icon);

	orientationLock: bLock ? (app.inPortrait ? PageOrientation.LockPortrait : PageOrientation.LockLandscape) : (settings.iOrientation === 1 ? PageOrientation.LockPortrait : (settings.iOrientation === 2 ? PageOrientation.LockLandscape : PageOrientation.Automatic));
	objectName: "idBasePage";

	BusyIndicator{
		id: indicator;
		anchors.centerIn: parent;
		z: constants._iMaxZ;
		running: root.bBusy;
		visible: running;
		platformStyle: BusyIndicatorStyle{
			size: "large";
			inverted: constants._bInverted;
		}
	}

	function _Init()
	{
	}

	function _DeInit()
	{
	}

	ToolIcon{
		anchors.left: parent.left;
		anchors.top: parent.top;
		opacity: 0.6;
		iconId: "toolbar-back";
		z: 10;
		visible: (pageStack != null && pageStack.depth > 1) && (root.eIconMode & 1 !== 0);
		onClicked: {
			root.iconClicked(1);
			pageStack.pop(undefined, root.bPopI);
		}
	}
	ToolIcon{
		anchors.right: parent.right;
		anchors.top: parent.top;
		opacity: 0.6;
		iconId: "toolbar-view-menu";
		z: 10;
		visible: root.menus != null && (root.eIconMode & 2 !== 0);
		onClicked: {
			root.iconClicked(2);
			root.menus.open();
		}
	}
}
