import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "widget"
import "../js/util.js" as Util

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
			var sw = Util.ParseBoolean(_UT.GetSetting("show_warning"));
			if(sw && !nw)
			{
				obj.dialog = controller._Info(
					qsTr("Warning"),
					qsTr("Read this notice before using this application"),
					[
						{
							text: qsTr("Your account must be access login on web, and you must to login by scanning QRCode with your another mobile client, and the mobile client should not offline."),
						},
						{
							text: qsTr("If shown '301' when you login successful, it means your account can not access Web client."),
						},
						{
							text: qsTr("And your account has some problem, I will not assumed liabilities."),
						},
						{
							text: qsTr("If you are worried about some exceptions on your account, please do not use this application!."),
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

	MouseArea{
		property variant __comp: null;
		property variant __test: null;
		//enabled: _UT.dev !== 0;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		width: 64;
		height: width;
		onClicked: {
			_Dev();
		}
		Component.onCompleted: {
			if(_UT.dev > 0) _Dev();
		}
		function _Dev()
		{
			if(!__comp)
			__comp = Qt.createComponent("Test.qml");
			if(__test)
			{
				__test.destroy();
				__test = null;
			}
			else
			{
				__test = __comp.createObject(root);
				controller._ShowMessage("open dev");
			}
		}
	}

	// Test{ id: test; }
}
