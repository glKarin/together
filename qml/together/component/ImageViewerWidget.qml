import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	objectName: "idImageViewerWidget";

	property alias cTextColor: text.color;
	property alias source: image.source;
	signal textClicked(variant mouse);

	Text{
		id: text;
		anchors.fill: parent;
		horizontalAlignment: Text.AlignHCenter;
		verticalAlignment: Text.AlignVCenter;
		font.bold: true;
		font.pixelSize: constants._iFontSuper;
		elide: Text.ElideRight;
		clip: true;
		color: constants._cDisableColor;
		visible: image.status === Image.Error;
		text: {
			switch(image.status)
			{
				case Image.Loading:
				return qsTr("Loading");
				case Image.Error:
				return qsTr("Load error");
				case Image.Null:
				return qsTr("No image");
				case Image.Ready:
				default:
				return "";
			}
		}
		MouseArea{
			anchors.centerIn: parent;
			width: parent.paintedWidth;
			height: parent.paintedHeight;
			onClicked: root.textClicked(mouse);
		}
	}

	Flickable{
		id: flick;
		anchors.fill: parent;
		clip: true;
		contentWidth: Math.max(image.width, width);
		contentHeight: Math.max(image.height, height);

		PinchArea{
			anchors.fill: parent;
			onPinchUpdated: {
				var delta = pinch.scale - pinch.previousScale;
				if(image.zoom + delta <= 0.0)
					image.zoom = 0.1;
				else
					image.zoom += delta;
			}
		}

		AnimatedImage{
			id: image;
			property real zoom: 1.0;
			property real factory: 1.0;
			anchors.centerIn: parent;
			width: sourceSize.width * factory * zoom;
			height: sourceSize.height * factory * zoom;
			smooth: true;
			cache: true;
			z: 1;
			onSourceChanged: {
				zoom = 1.0;
				factory = 1.0;
				flick.contentX = 0;
				flick.contentY = 0;
				playing = true;
			}
			onStatusChanged: {
				_Update();
			}
			MouseArea{
				anchors.fill: parent;
				onDoubleClicked: {
					if(image.zoom != 1.0)
					{
						anim.to = 1.0;
						flick.contentX = 0;
						flick.contentY = 0;
					}
					else anim.to = 2.0;
					anim.restart();
				}
			}
			NumberAnimation on zoom{
				id: anim;
				to: 1.0;
				duration: 180;
				running: false;
			}

			function _Update()
			{
				if(status === Image.Ready)
				{
					if(sourceSize.height == 0 || flick.height == 0 || sourceSize.width == 0 || flick.width == 0)
					{
						factory = 0;
						return;
					}

					factory = Util.CaleImageZoomFactory(sourceSize.width, sourceSize.height, flick.width, flick.height);
				}
			}
		}

		onWidthChanged: {
			image._Update();
		}
		onHeightChanged: {
			image._Update();
		}
	}

	ScrollDecorator{
		flickableItem: flick;
	}

	BusyIndicator{
		id: indicator;
		anchors.centerIn: parent;
		z: 2;
		platformStyle: BusyIndicatorStyle{
			size: "large";
			inverted: true;
		}
		visible: image.status === Image.Loading;
		running: visible;
	}
}
