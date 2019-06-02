import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script

// MainPage
BasePage{
	id: root;

	sTitle: _UT.Get("NAME");
	objectName: "idMainPage";
	menus: mainmenu;

	HomeTabMenuWidget{
		id: mainmenu;
		currentTab: pathview.currentIndex;
		onShowTab: {
			pathview.currentIndex = index;
		}
	}

	function _Init()
	{
		pathview.currentIndex = 2;
		obj._GetInitData();
	}

	QtObject{
		id: obj;
		function _GetInitData(force)
		{
			if(!globals._IsValid()) return;

			if(!force && sessionmodel.__inited) return;

			root.bBusy = true;
			sessionmodel._Reset();
			var s = function(data){
				globals._SetUserInfo(data.userinfo);
				globals.synckey = data.synckey;
				globals._Dump();
				sessionmodel._SetData(data.data);
				root.bBusy = false;
			};
			var f = function(err){
				controller._ShowMessage(err);
				root.bBusy = false;
			};

			Script.GetInitData(undefined, s, f);
		}
	}

	PathView{
		id: pathview;
		anchors.fill: parent;
		model: ListModel{
			ListElement{
				page: "HomeItem.qml";
			}
			ListElement{
				page: "ContactItem.qml";
			}
			ListElement{
				page: "ProfileItem.qml";
			}
		}

		delegate: Component{
			Item{
				id: rect;
				width: PathView.view.width;
				height: PathView.view.height;
				clip: true;
				Loader{
					id: loader;
					anchors.fill: parent;
				}
				Component.onCompleted: {
					loader.sourceComponent = Qt.createComponent(Qt.resolvedUrl(model.page));
				}
				Connections{
					target: rect.PathView.view;
					onCurrentIndexChanged: {
					 if(loader.item && rect.PathView.view.currentIndex == loader.item._index)
					 {
						 loader.item._Init();
					 }
					}
				}
				/*
				 PathView.onIsCurrentItemChanged: {
					 console.log(PathView.view.currentIndex, loader.item.objectName, PathView.isCurrentItem);
					 if(PathView.isCurrentItem && loader.item)
					 {
						 loader.item._Init();
					 }
				 }
				 */ // now visble item is not current item
			}
		}
		clip: true;
		flickDeceleration: 5000;
		//dragMargin:-400;
		path: Path{
			startX: -1 * pathview.width + pathview.width / 2;
			startY: pathview.height / 2;
			PathLine{
				x: 2 * pathview.width + pathview.width / 2;
				y: pathview.height / 2;
			}
		}
	}

	Component.onCompleted: {
		controller._ShowMessage(qsTr("You can swipe or select menu to change view."));
	}
}
