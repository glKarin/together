import QtQuick 1.1
import "../js/util.js" as Util

QtObject {
	id: root;

	objectName: "idControllerObject";
	property variant __queryDialog: null;
	property variant __selectionDialog: null;
	property variant __infoDialog: null;

	// util
	function _CheckLogin()
	{
		if(globals._IsValid()) return true;
		else
		{
			_OpenLoginPage(true);
			return false;
		}
	}

	// page
	function _OpenHomePage(im)
	{
		if(_IsCurrentPage("Main")) return;
		if(!_CheckLogin()) return;
		pageStack.clear();
		var page = Qt.createComponent(Qt.resolvedUrl("MainPage.qml"));
		var p = pageStack.push(page, undefined, im);
		p._Init();
		return p;
	}

	function _OpenSplashPage(w, im)
	{
		if(_IsCurrentPage("Splash")) return;
		pageStack.clear();
		var page = Qt.createComponent(Qt.resolvedUrl("SplashPage.qml"));
		var p = pageStack.push(page, undefined, im);
		p._Init(w);
		return p;
	}

	function _OpenLoginPage(im)
	{
		if(_IsCurrentPage("Login")) return;
		var page = Qt.createComponent(Qt.resolvedUrl("LoginPage.qml"));
		var p = pageStack.push(page, undefined, im);
		p._Init();
		return p;
	}

	function _OpenProfilePage(im)
	{
		if(_IsCurrentPage("Profile")) return;
		if(!_CheckLogin()) return;
		var page = Qt.createComponent(Qt.resolvedUrl("ProfilePage.qml"));
		var p = pageStack.push(page, undefined, im);
		p._Init();
		return p;
	}

	function _OpenArticlePage(url, im)
	{
		if(_IsCurrentPage("Article")) return;
		if(!_CheckLogin()) return;
		var page = Qt.createComponent(Qt.resolvedUrl("ArticlePage.qml"));
		var p = pageStack.push(page, undefined, im);
		p._Init(url);
		return p;
	}

	function _OpenSessionPage(uname, im)
	{
		if(_IsCurrentPage("Session"))
		{
			//pageStack.currentPage._Init(uname);
			return;
		}
		if(!_CheckLogin()) return;
		var page = Qt.createComponent(Qt.resolvedUrl("SessionPage.qml"));
		var p = pageStack.push(page, undefined, im);
		p._Init(uname);
		return p;
	}

	function _OpenSettingPage(im)
	{
		if(_IsCurrentPage("Setting")) return;
		var page = Qt.createComponent(Qt.resolvedUrl("SettingPage.qml"));
		var p = pageStack.push(page, undefined, im);
		return p;
	}

	function _OpenUrl(url, type, im)
	{
		var t = type === undefined ? settings.iDefaultBrowser : type;
		if(t == 0)
		{
			//if(_IsCurrentPage("Browser")) return;
			var page = Qt.createComponent(Qt.resolvedUrl("BrowserPage.qml"));
			var p= pageStack.push(page, undefined, im);
			p._Init(url);
		}
		else Qt.openUrlExternally(url);
	}

	function _OpenUserPage(u, im)
	{
		if(_IsCurrentPage("User")) return;
		if(!_CheckLogin()) return;
		var page = Qt.createComponent(Qt.resolvedUrl("UserPage.qml"));
		var p = pageStack.push(page, undefined, im);
		p._Init(u);
		return p;
	}

	function _OpenAboutPage(im)
	{
		if(_IsCurrentPage("About")) return;
		var page = Qt.createComponent(Qt.resolvedUrl("AboutPage.qml"));
		pageStack.push(page, undefined, im);
	}

	function _OpenBDTBHome(u)
	{
		var url = "http://tieba.baidu.com/home/main?un=" + u;
		_OpenUrl(url);
	}

	// hide
	function __Test(data)
	{
		if(_UT.dev === 0)
		{
			_ShowMessage("Only for developer");
			return;
		}

	}

	// util
	function _ShowMessage(msg)
	{
		console.log(msg);
		infobanner._ShowMessage(msg);
	}

	function _CopyToClipboard(text, name)
	{
		_UT.CopyToClipboard(text);
		_ShowMessage(qsTr("Copy %1 to clipboard successful").arg(name ? name : qsTr("data")));
		console.log("Copy data -> " + text);
	}

	function _Query(title, message, acceptText, rejectText, acceptCallback, rejectCallback)
	{
		if(!__queryDialog)
		{
			__queryDialog = Qt.createComponent("component/DynamicQueryDialog.qml");
		}
		var msg = Array.isArray(message) ? message.join("\n") : message;
		var prop = {
			titleText: title,
			message: msg + "\n",
			acceptButtonText: acceptText,
			rejectButtonText: rejectText
		};
		var diag = __queryDialog.createObject(pageStack.currentPage, prop);
		if(typeof(acceptCallback) === "function") diag.accepted.connect(acceptCallback);
		if(typeof(rejectCallback) === "function") diag.rejected.connect(rejectCallback);

		return diag;
	}

	function _Info(title, subtitle, content, bottomtitle, handlelink, refresh, footer)
	{
		if(!__infoDialog)
		{
			__infoDialog = Qt.createComponent("component/InfoDialog.qml");
		}
		var prop = {
			titleText: title,
			sTitle: subtitle,
			aTexts: content,
			sBottomTitle: bottomtitle || "",
		};
		var diag = __infoDialog.createObject(pageStack.currentPage, prop);
		if(typeof(handlelink) === "function") diag.linkClicked.connect(handlelink);
		if(typeof(refresh) === "function") diag.clicked.connect(refresh);
		if(typeof(footer) === "function") diag.footerClicked.connect(footer);

		return diag;
	}

	function _Select(title, model, selection_func, field, cur_selected)
	{
		if(!__selectionDialog)
		{
			__selectionDialog = Qt.createComponent("component/DynamicSelectionDialog.qml");
		}
		var prop = {
			titleText: title,
			sField: field || "",
			model: model, // QStringList | JS string array => modelData
			selectedIndex: cur_selected,
		};
		var diag = __selectionDialog.createObject(pageStack.currentPage, prop);
		if(typeof(selection_func) === "function") diag.select.connect(selection_func);

		return diag;
	}

	function _IsCurrentPage(name)
	{
		return(pageStack && pageStack.currentPage && pageStack.currentPage.objectName === "id" + name + "Page");
	}
}
