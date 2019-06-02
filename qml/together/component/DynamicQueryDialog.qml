import QtQuick 1.1
import com.nokia.meego 1.1

QueryDialog{
	id: root;
	objectName: "idQueryDialog";
	property bool bAutoDestroy: true;
	property bool bAutoOpen: true;

	property bool __isClosing: false;

	onStatusChanged: {
		if(bAutoDestroy)
		{
			if (status == DialogStatus.Closing)
			{
				__isClosing = true;
			}
			else if (status == DialogStatus.Closed && __isClosing)
			{
				root.destroy(250);
			}
		}
	}
	Component.onCompleted: {
		if(bAutoOpen) open();
	}
}
