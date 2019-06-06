import QtQuick 1.1
import com.nokia.meego 1.1
import karin.together 1.0

Item{
	id: root;
	property alias title: webview.title;
	property alias progress: webview.progress;
	property alias url: webview.url;
	property alias bCanGoBack: webview.canGoBack;
	property alias bCanGoForward: webview.canGoForward;
	property alias icon: webview.icon;
	property alias settings: webview.settings;
	property alias dontDelegateLinks: webview.dontDelegateLinks;
	property bool bBrowserHelper: false;
	property bool bAllowDblZoom: false;
	property bool bLoadImage: false;
	signal linkClicked(url link);
	signal alert(string message);

	objectName: "idWebPageWidget";
	function forward()
	{
		webview.forward.trigger();
	}

	function back()
	{
		webview.back.trigger();
	}

	function reload()
	{
		webview.reload.trigger();
	}

	function stop()
	{
		webview.stop.trigger();
	}

	Slider{
		id: hslider;
		anchors{
			bottom: parent.bottom;
			left: parent.left;
			right: vslider.left;
		}
		z: 1;
		minimumValue: 0;
		maximumValue: Math.max(flick.contentWidth - flick.width, 0);
		visible: root.bBrowserHelper;
		stepSize: 1;
		value: flick.contentX;
		height: visible ? constants._iSizeLarge : 0;
		onValueChanged: {
			if(pressed)
			{
				flick.contentX = value;
			}
		}
	}

	Slider{
		id: vslider;
		anchors{
			top: parent.top;
			bottom: parent.bottom;
			right: parent.right;
		}
		z: 1;
		stepSize: 1;
		inverted: true;
		width: visible ? constants._iSizeLarge : 0;
		visible: root.bBrowserHelper;
		minimumValue: 0;
		maximumValue: Math.max(flick.contentHeight - flick.height, 0);
		value: flick.contentY;
		orientation: Qt.Vertical;
		onValueChanged: {
			if(pressed)
			{
				flick.contentY = value;
			}
		}
	}

	Flickable{
		id: flick;
		anchors.fill: parent;
		anchors.rightMargin: vslider.width;
		anchors.bottomMargin: hslider.height;
		contentWidth: Math.max(width, webview.width);
		contentHeight: Math.max(height, webview.height);
		clip: true;
		TogetherWebView{
			id: webview;
			preferredWidth: flick.width;
			preferredHeight: flick.height;
			settings.autoLoadImages: root.bLoadImage;
			onLinkClicked: {
				root.linkClicked(link);
			}
			onAlert: {
				root.alert(message);
			}
			onZoomTo: doZoom(zoom,centerX, centerY)
			onContentsSizeChanged: {
				contentsScale = Math.min(1, flick.width / contentsSize.width)
			}
			onJavaScriptConsoleMessage: console.log("[Browser Console]: %1 -> %3:%2".arg(message).arg(lineNumber).arg(sourceID));
			//onUrlChanged:
			onLoadStarted: {
				flick.contentX = 0
				flick.contentY = 0
			}
			onDoubleClick: {
				if(root.bAllowDblZoom)
				{
					if (!heuristicZoom(clickX,clickY,2.5)) {
						var zf = flick.width / contentsSize.width
						if (zf >= contentsScale)
						zf = 2.0*contentsScale // zoom in (else zooming out)
						doZoom(zf,clickX*zf,clickY*zf)
					}
				}
			}
			function doZoom(zoom,centerX,centerY)
			{
				if (centerX) {
					var sc = zoom*contentsScale;
					scaleAnim.to = sc;
					flickVX.from = flick.contentX
					flickVX.to = Math.max(0,Math.min(centerX-flick.width/2,webview.width*sc-flick.width))
					finalX.value = flickVX.to
					flickVY.from = flick.contentY
					flickVY.to = Math.max(0,Math.min(centerY-flick.height/2,webview.height*sc-flick.height))
					finalY.value = flickVY.to
					quickZoom.start()
				}
			}
		}
		SequentialAnimation {
			id: quickZoom

			PropertyAction {
				target: webview
				property: "renderingEnabled"
				value: false
			}
			ParallelAnimation {
				NumberAnimation {
					id: scaleAnim
					target: webview
					property: "contentsScale"
					easing.type: Easing.Linear
					duration: 200
				}
				NumberAnimation {
					id: flickVX
					target: flick
					property: "contentX"
					easing.type: Easing.Linear
					duration: 200
					from: 0
					to: 0
				}
				NumberAnimation {
					id: flickVY
					target: flick
					property: "contentY"
					easing.type: Easing.Linear
					duration: 200
					from: 0
					to: 0
				}
			}
			PropertyAction {
				id: finalX
				target: flick
				property: "contentX"
				value: 0
			}
			PropertyAction {
				id: finalY
				target: flick
				property: "contentY"
				value: 0
			}
			PropertyAction {
				target: webview
				property: "renderingEnabled"
				value: true
			}
		}
	}

	ScrollDecorator{
		flickableItem: flick;
	}
}
