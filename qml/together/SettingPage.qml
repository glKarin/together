import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: qsTr("Setting");
	objectName: "idSettingPage";
	menus: menu;

	ContextMenu{
		id: menu;
		MenuLayout{
			MenuItem{
				enabled: obj.recordCacheSize > 0;
				text: qsTr("Clear voice record") + ": " + Util.FormatFileSize(obj.recordCacheSize);
				onClicked: {
					obj._ClearLocalStorage("VOICE_RECORD");
				}
			}
			MenuItem{
				enabled: obj.tempCacheSize > 0;
				text: qsTr("Clear temp cache") + ": " + Util.FormatFileSize(obj.tempCacheSize);
				onClicked: {
					obj._ClearLocalStorage("TEMP_CACHE");
				}
			}
			MenuItem{
				text: qsTr("Download") + ": " + Util.FormatFileSize(obj.downloadCacheSize);
				enabled: false;
			}
			MenuItem{
				text: qsTr("Reset settings");
				onClicked: {
					obj._ResetSettings();
				}
			}
		}
	}

	function _Init()
	{
		obj._CaleCacheSize();
	}

	QtObject{
		id: obj;
		property int recordCacheSize: 0;
		property int tempCacheSize: 0;
		property int downloadCacheSize: 0;

		function _CaleCacheSize()
		{
			var cache = _UT.GetStorageInfo();
			recordCacheSize = cache["VOICE_RECORD"];
			tempCacheSize = cache["TEMP_CACHE"];
			downloadCacheSize = cache["DOWNLOAD"];
		}

		function _ClearLocalStorage(type)
		{
			controller._Query(
				qsTr("WARNING"),
				qsTr("It will remove local files! Are you sure?"),
				qsTr("Clear"), qsTr("Cancel"),
				function(){
					_UT.ClearLocalStorage(type);
					obj._CaleCacheSize();
				}
			);
		}

		function _ResetSettings()
		{
			controller._Query(
				qsTr("WARNING"),
				qsTr("It will reset all settings! Are you sure?"),
				qsTr("Reset"), qsTr("Cancel"),
				function(){
					settings._ResetSetting();
					_ReadSettings();
				}
			);
		}

		function _ReadSettings()
		{
			orientation.vCurrentValue = settings.iOrientation;
			nightMode.checked = settings.bNightMode;
			defaultBrowser.vCurrentValue = settings.iDefaultBrowser;
			fullscreen.checked = settings.bFullscreen;
			checkUpdate.checked = settings.bCheckUpdate;

			browserHelper = settings.bBrowserHelper;
			browserDblZoom = settings.bBrowserDblZoom;
			browserLoadImage = settings.bBrowserLoadImage;

			syncInterval.value = settings.iSyncInterval;
			runMode.vCurrentValue = settings.eRunMode;
			syncBackground.value = settings.iSyncBackground;
			onlineBackground.value = settings.iOnlineBackground;
			onlineCheck.checked = settings.bOnlineCheck;
			showNotification.checked = settings.bShowNotification;
		}
	}

	ButtonRow{
		id: header;
		anchors.top: parent.top;
		anchors.horizontalCenter: parent.horizontalCenter;
		width: parent.width;
		height: constants._iSizeXL;
		TabButton{
			height: parent.height;
			text: qsTr("General");
			tab: generalflick;
		}
		TabButton{
			height: parent.height;
			text: qsTr("Chat");
			tab: chatflick;
		}
	}

	TabGroup{
		anchors.top: header.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.bottomMargin: constants._iSpacingMedium;
		currentTab: generalflick;

		Flickable{
			id: generalflick;
			anchors.fill: parent;
			contentWidth: width;
			contentHeight: generallayout.height;
			clip: true;
			Column{
				id: generallayout;
				anchors.verticalCenter: parent.verticalCenter;
				width: parent.width;
				spacing: constants._iSpacingXXL;

				SelectWidget{
					id: orientation;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Orientation");
					aOptions: [
						{
							name: qsTr("Automatic"),
							value: 0,
						},
						{
							name: qsTr("Portrait"),
							value: 1,
						},
						{
							name: qsTr("Landscape"),
							value: 2,
						},
					]
					vCurrentValue: settings.iOrientation;
					onSelected: {
						settings.iOrientation = value;
					}
				}

				SwitcherWidget{
					id: nightMode;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Night mode");
					checked: settings.bNightMode;
					onCheckedChanged: {
						settings.bNightMode = checked;
					}
				}

				SwitcherWidget{
					id: fullscreen;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Fullscreen");
					checked: settings.bFullscreen;
					onCheckedChanged: {
						settings.bFullscreen = checked;
					}
				}

				SelectWidget{
					id: defaultBrowser;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Default browser");
					aOptions: [
						{
							name: qsTr("Internal"),
							value: 0,
						},
						{
							name: qsTr("System"),
							value: 1,
						},
					]
					vCurrentValue: settings.iDefaultBrowser;
					onSelected: {
						settings.iDefaultBrowser = value;
					}
				}

				SwitcherWidget{
					id: checkUpdate;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Check update on start");
					checked: settings.bCheckUpdate;
					onCheckedChanged: {
						settings.bCheckUpdate = checked;
					}
				}


				SwitcherWidget{
					id: browserHelper;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Browser helper");
					checked: settings.bBrowserHelper;
					onCheckedChanged: {
						settings.bBrowserHelper = checked;
					}
				}

				SwitcherWidget{
					id: browserLoadImage;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Browser load image");
					checked: settings.bBrowserLoadImage;
					onCheckedChanged: {
						settings.bBrowserLoadImage = checked;
					}
				}

				SwitcherWidget{
					id: browserDblZoom;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Browser double-click zoom");
					checked: settings.bBrowserDblZoom;
					onCheckedChanged: {
						settings.bBrowserDblZoom = checked;
					}
				}
			}
		}
		ScrollDecorator{
			flickableItem: generalflick;
		}

		Flickable{
			id: chatflick;
			anchors.fill: parent;
			contentWidth: width;
			contentHeight: chatlayout.height;
			clip: true;
			Column{
				id: chatlayout;
				anchors.verticalCenter: parent.verticalCenter;
				width: parent.width;
				spacing: constants._iSpacingXXL;

				SelectWidget{
					id: runMode;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Run mode");
					aOptions: [
						{
							name: qsTr("Application quit when window closed"),
							value: 0,
						},
						{
							name: qsTr("Run on background and hide window"),
							value: 1,
						},
						{
							name: qsTr("Run on background and close window"),
							value: 2,
							enabled: _UT.dev ? true : false,
						},
					]
					vCurrentValue: settings.eRunMode;
					onSelected: {
						if(disable)
						{
							controller._ShowMessage("[%1]: %2".arg(qsTr("WARNING")).arg(qsTr("This mode is only for development.")));
						}
						else
						{
							settings.eRunMode = value;
							controller._ShowMessage("[%1]: %2".arg(qsTr("WARNING")).arg(qsTr("Run mode setting will be used in next running.")));
						}
					}
				}
				SliderWidget{
					id: syncInterval;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Sync interval");
					iPrecision: 0;
					minimumValue: 1;
					maximumValue: 60;
					stepSize: 1;
					bAutoLabel: false;
					sCurText: "" + value + qsTr("Sec");
					sMinText: "" + minimumValue + qsTr("Sec");
					sMaxText: "" + maximumValue + qsTr("Sec");
					value: settings.iSyncInterval;
					onValueChanged /*onMove*/: {
						settings.iSyncInterval = value;
					}
				}

				SliderWidget{
					id: syncBackground;
					visible: true;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Sync interval on background");
					iPrecision: 0;
					minimumValue: 1;
					maximumValue: 600;
					stepSize: 1;
					bAutoLabel: false;
					sCurText: "" + value + qsTr("Sec");
					sMinText: "" + minimumValue + qsTr("Sec");
					sMaxText: "" + maximumValue + qsTr("Sec");
					value: settings.iSyncBackground;
					onValueChanged /*onMove*/: {
						settings.iSyncBackground = value;
					}
				}

				SwitcherWidget{
					id: onlineCheck;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Repeat to send empty message to filehelper");
					checked: settings.bOnlineCheck;
					onCheckedChanged: {
						settings.bOnlineCheck = checked;
						if(settings.bOnlineCheck)
						{
							controller._ShowMessage(qsTr("Repeat to send message for keeping alive, and empty message will not send to session. Do not set a too short interval."));
						}
						else
						{
							controller._ShowMessage(qsTr("Open this can keep account alive."));
						}
					}
				}

				SliderWidget{
					id: onlineBackground;
					visible: settings.bOnlineCheck;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Send interval");
					iPrecision: 0;
					minimumValue: 1;
					maximumValue: 20;
					stepSize: 1;
					bAutoLabel: false;
					sCurText: "" + value + qsTr("Min");
					sMinText: "" + minimumValue + qsTr("Min");
					sMaxText: "" + maximumValue + qsTr("Min");
					value: settings.iOnlineBackground;
					onValueChanged /*onMove*/: {
						settings.iOnlineBackground = value;
					}
				}

				SwitcherWidget{
					id: showNotification;
					iMargins: constants._iSpacingLarge;
					sText: qsTr("Show notification when new message coming.");
					checked: settings.bShowNotification;
					onCheckedChanged: {
						settings.bShowNotification = checked;
					}
				}

			}
		}
		ScrollDecorator{
			flickableItem: chatflick;
		}
	}
}
