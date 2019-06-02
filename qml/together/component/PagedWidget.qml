import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root
	property int pageNo: 0;
	property int pageSize: 20;
	property int pageCount: 0;
	property int totalCount: 0;

	signal prev;
	signal next;
//	signal jump(int page);

	height: constants._iSizeXL;
	width: constants._iSizeBig;
	objectName: "idPagedWidget";
	opacity: 0.6;
	z: 1;
	//clip: true; // for icon moving everywhere

	ToolBarLayout{
		anchors.fill: parent;
		visible: root.pageCount > 1;
		IconWidget{
			iconId: "toolbar-previous";
			enabled: root.pageNo > 1;
			onClicked: {
				root.prev();
			}
		}
		IconWidget{
			iconId: "toolbar-next";
			enabled: root.pageNo < root.pageCount;
			onClicked: {
				root.next();
			}
		}
	}
}
