import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/main.js" as Script

// MainPage
BasePage{
	id: root;

	sTitle: qsTr("Splash");
	objectName: "idSplashPage";

	function _Init(nw)
	{
		obj._CheckLogin(nw, true);
	}

	QtObject{
		id: obj;
		property variant dialog: null;

		function _CheckLogin(nw, r)
		{
			if(_UT.GetSetting("show_warning") && !nw)
			{
				obj.dialog = controller._Info(
					qsTr("Warning"),
					qsTr("Read this notice before using this application"),
					[
						{
							text: qsTr("Your account must be access login on web."),
						},
						{
							text: qsTr("And your account has some problem, I will not assumed liabilities."),
						},
						{
							text: qsTr("The application is based on Web API."),
						},
						{
							text: qsTr("It means not get ID and telphone number of your and your contacts."),
						},
						{
							text: qsTr("All your login data is random for this time, and is invalid on next time."),
						},
					],
					"<a href='_UT.SetSetting(\"show_warning\", false); controller._OpenHomePage(true);'>" + qsTr("Do not show this") + "</a>"
					+ " <a href='controller._OpenHomePage(true);'>" + qsTr("Accept") + "</a>"
					+ " <a href='Qt.quit();'>" + qsTr("Reject") + "</a>"
					,
					function(link){
						if(obj.dialog) obj.dialog.accept();
						eval(link);
						obj.dialog = null;
					},
					undefined,
					function(link){
						if(obj.dialog) obj.dialog.accept();
						if(r && _UT.runMode == 2) globals._Restore();
						eval(link);
						obj.dialog = null;
					}
				);
			}
			else
			{
				if(r && _UT.runMode == 2) globals._Restore();
				controller._OpenHomePage(true);
			}
		}
	}

	Image{
		id: code;
		anchors.fill: parent;
		//cache: false;
		smooth: true;
		/*
		 sourceSize.width: width;
		 sourceSize.height: height;
		 */
		source: _UT.Get("SPLASH");
		fillMode: Image.PreserveAspectCrop;
	}

	Row{
		anchors.bottom: parent.bottom;
		anchors.horizontalCenter: parent.horizontalCenter;
		z: 1;
		opacity: 0.6;
		spacing: constants._iSpacingBig;
		Button{
			text: qsTr("Login");
			width: constants._iSizeXXXL;
			onClicked: {
				obj._CheckLogin(false, true);
			}
		}
		Button{
			text: qsTr("Quit");
			width: constants._iSizeXXXL;
			onClicked: {
				Qt.quit();
			}
		}
	}
}
