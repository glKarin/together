import QtQuick 1.1
import com.nokia.meego 1.1

QtObject {
    id: root;
		objectName: "idConstantsObject";

    property int _iHeaderHeight: 64;
    property int _iHeaderZ: 100;
    property int _iMenuZ: 200;
    property color _cHeaderTitleColor: "#ffffff";

    property int _iMaxZ: 999;
		// Maemo/Harmattan is landscape
		property int _iMaxWidth: screen.displayHeight;
		property int _iMaxHeight: screen.displayWidth;

    property int _iFontMicro: 10;
    property int _iFontTiny: 12;
    property int _iFontSmall: 16;
    property int _iFontMedium: 18;
    property int _iFontLarge: 20;
    property int _iFontXL: 24;
    property int _iFontXXL: 28;
    property int _iFontXXXL: 32;
    property int _iFontBig: 40;
    property int _iFontTooBig: 48;
    property int _iFontSuper: 64;


		property int _iSpacingMicro: 1;
		property int _iSpacingTiny: 2;
		property int _iSpacingSmall: 4;
		property int _iSpacingMedium: 6;
		property int _iSpacingLarge: 8;
		property int _iSpacingXL: 10;
		property int _iSpacingXXL: 12;
		property int _iSpacingXXXL: 16;
		property int _iSpacingBig: 18;
		property int _iSpacingTooBig: 20;
		property int _iSpacingSuper: 24;


    property int _iSizeMicro: 4;
    property int _iSizeTiny: 16;
    property int _iSizeSmall: 24;
    property int _iSizeMedium: 32;
    property int _iSizeLarge: 48;
    property int _iSizeXL: 64;
    property int _iSizeXXL: 80;
    property int _iSizeXXXL: 128;
    property int _iSizeBig: 180;
    property int _iSizeTooBig: 240;
    property int _iSizeSuper: 320;


		property color _cLightColor: "#FFFFFF";
		property color _cDarkColor: "#000000";

		property color _cPrimaryColor: !_bInverted ? "#000000" : "#ffffff";
		property color _cSecondaryColor: !_bInverted ? "#666666" : "#999999";
		property color _cBackgroundColor: !_bInverted ? "#cccccc" : "#333333";
		property color _cHighlightColor: !_bInverted ? "#333333" : "#cccccc";
		property color _cDisableColor: !_bInverted ? "#999999" : "#666666";
		property color _cClearColor: !_bInverted ? "#FFFFFF" : "#000000";
		property color _cErrorColor: !_bInverted ? "#FF0000" : "#FF0000";

		property color _cGlobalColor: _bInverted ? _cNightColor : _cThemeColor;
		property color _cThemeColor: "#9eea6a";
		property bool _bInverted: settings.bNightMode;
		property color _cTransparent: "#00000000";
		property color _cNightColor: "#2d2d2d";



		property string _sPrevPage: "_Prev";
		property string _sNextPage: "_Next";
		property string _sThisPage: "_This";
		property string _sFirstPage: "_First";
		property string _sLastPage: "_Last";

		property string _sShowState: "_Show";
		property string _sHideState: "_Hide";

		property string _sAlignLeft: "_Left";
		property string _sAlignCenter: "_Center";
		property string _sAlignRight: "_Right";


	}
