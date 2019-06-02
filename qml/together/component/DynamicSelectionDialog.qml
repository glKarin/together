import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

SelectionDialog{
	id: root;
	objectName: "idSelectionDialog";
	property bool bAutoDestroy: true;
	property bool bAutoOpen: true;
	property string sField: "";
	signal select(int index, string field, variant data);

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

	onAccepted: {
		if(selectedIndex !== -1) root.select(selectedIndex, sField, Util.ModelGet(model, selectedIndex));
	}
}
