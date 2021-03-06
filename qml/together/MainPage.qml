import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script
import "../js/util.js" as Util

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
		pathview.currentIndex = 3;
		obj._GetInitData(true);
	}

	QtObject{
		id: obj;
		function _GetInitData(force)
		{
			if(!globals._IsValid()) return;

			if(!force && sessionmodel.__inited) return;

			root.bBusy = true;
			appobj._Reset();
			sessionmodel._Reset();
			subscribemodel._Reset();
			var s = function(data){
				globals._SetUserInfo(data.userinfo);
				globals.synckey = data.synckey;
				globals._Dump();
				sessionmodel._SetData(data.data);
				obj._GetGroupInitData();
				subscribemodel._SetData(data.subscribe_data);
				root.bBusy = false;
			};
			var f = function(err){
				controller._ShowMessage(err);
				root.bBusy = false;
			};

			Script.GetInitData(undefined, s, f);
		}

		function _GetGroupInitData()
		{
			if(!globals._IsValid()) return;
			if(!sessionmodel.__inited) return;

			var unames = [];
			Util.ModelForeach(sessionmodel, function(e){
				if(Script.idAPI.IsGroupUname(e.uname))
				unames.push(e.uname);
			});
			if(unames.length > 0)
			{
				appobj._GetUserContact(unames, function(data){
					sessionmodel._UpdateData(data);
				});
			}
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
				page: "SubscribeItem.qml";
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
			//startX: -2 * pathview.width + pathview.width / 2;
			startY: pathview.height / 2;
			PathLine{
				x: 3 * pathview.width + pathview.width / 2;
				//x: 2 * pathview.width + pathview.width / 2;
				y: pathview.height / 2;
			}
		}
	}

	Component.onCompleted: {
		controller._ShowMessage(qsTr("You can swipe or select menu to change view."));
	}
}
