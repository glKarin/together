import QtQuick 1.1

QtObject {
	id: root;

	objectName: "idSettingsObject";
	property int iOrientation: _UT.GetSetting("generals/orientation");
	onIOrientationChanged: _UT.SetSetting("generals/orientation", iOrientation);

	property int iThemeColor: _UT.GetSetting("generals/theme_color");
	onIThemeColorChanged: _UT.SetSetting("generals/theme_color", iThemeColor);

	property bool bNightMode: _UT.GetSetting("generals/night_mode");
	onBNightModeChanged: _UT.SetSetting("generals/night_mode", bNightMode);

	property int iDefaultBrowser: _UT.GetSetting("generals/default_browser");
	onIDefaultBrowserChanged: _UT.SetSetting("generals/default_browser", iDefaultBrowser);

	property bool bFullscreen: _UT.GetSetting("generals/fullscreen");
	onBFullscreenChanged: _UT.SetSetting("generals/fullscreen", bFullscreen);

	property bool bCheckUpdate: _UT.GetSetting("generals/check_update");
	onBCheckUpdateChanged: _UT.SetSetting("generals/check_update", bCheckUpdate);

	property string sLastFileSystemPath: _UT.GetSetting("generals/last_file_system_path");
	onSLastFileSystemPathChanged: _UT.SetSetting("generals/last_file_system_path", sLastFileSystemPath);



	property int iSyncInterval: _UT.GetSetting("chat/sync_interval");
	onISyncIntervalChanged: _UT.SetSetting("chat/sync_interval", iSyncInterval);

	property int eRunMode: _UT.GetSetting("generals/run_mode");
	onERunModeChanged: _UT.SetSetting("generals/run_mode", eRunMode);

	property int iSyncBackground: _UT.GetSetting("chat/sync_background");
	onISyncBackgroundChanged: _UT.SetSetting("chat/sync_background", iSyncBackground);

	property int iOnlineBackground: _UT.GetSetting("chat/online_background");
	onIOnlineBackgroundChanged: _UT.SetSetting("chat/online_background", iOnlineBackground);

	property bool bOnlineCheck: _UT.GetSetting("chat/online_check");
	onBOnlineCheckChanged: _UT.SetSetting("chat/online_check", bOnlineCheck);

	property bool bShowNotification: _UT.GetSetting("chat/show_notification");
	onBShowNotificationChanged: _UT.SetSetting("chat/show_notification", bShowNotification);



	property bool bBrowserHelper: _UT.GetSetting("browser/helper");
	onBBrowserHelperChanged: _UT.SetSetting("browser/helper", bBrowserHelper);

	property bool bBrowserDblZoom: _UT.GetSetting("browser/dbl_zoom");
	onBBrowserDblZoomChanged: _UT.SetSetting("browser/dbl_zoom", bBrowserDblZoom);

	property bool bBrowserLoadImage: _UT.GetSetting("browser/load_image");
	onBBrowserLoadImageChanged: _UT.SetSetting("browser/load_image", bBrowserLoadImage);


	function _ResetSetting(name)
	{
		_UT.ResetSetting(name);

		iOrientation = _UT.GetSetting("generals/orientation");
		iThemeColor = _UT.GetSetting("generals/theme_color");
		bNightMode = _UT.GetSetting("generals/night_mode");
		iDefaultBrowser = _UT.GetSetting("generals/default_browser");
		bFullscreen = _UT.GetSetting("generals/fullscreen");
		bCheckUpdate = _UT.GetSetting("generals/check_update");
		sLastFileSystemPath = _UT.GetSetting("generals/last_file_system_path");

		iSyncInterval = _UT.GetSetting("chat/sync_interval");
		eRunMode = _UT.GetSetting("generals/run_mode");
		iSyncBackground = _UT.GetSetting("chat/sync_background");
		iOnlineBackground = _UT.GetSetting("chat/online_background");
		bOnlineCheck = _UT.GetSetting("chat/online_check");
		bShowNotification = _UT.GetSetting("chat/show_notification");

		bBrowserHelper = _UT.GetSetting("browser/helper");
		bBrowserDblZoom = _UT.GetSetting("browser/dbl_zoom");
		bBrowserLoadImage = _UT.GetSetting("browser/load_image");
	}
}
