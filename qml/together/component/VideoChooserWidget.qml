import QtQuick 1.1
import com.nokia.meego 1.1
import QtMobility.gallery 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	objectName: "idVideoChooserWidget";

	property int iCellSpacing: 0;
	property string sFilePath;
	property string sFileName;

	signal select(string filePath, string fileName);

	function _Reload()
	{
		model.reload();
	}

	Text{
		anchors.fill: parent;
		horizontalAlignment: Text.AlignHCenter;
		verticalAlignment: Text.AlignVCenter;
		font.bold: true;
		font.pixelSize: constants._iFontSuper;
		elide: Text.ElideRight;
		clip: true;
		color: constants._cDisableColor;
		text: qsTr("No content");
		visible: view.count === 0;
		MouseArea{
			anchors.centerIn: parent;
			width: parent.paintedWidth;
			height: parent.paintedHeight;
		}
	}

	ListView{
		id: view;
		anchors.fill: parent;
		clip: true;

		model: DocumentGalleryModel{
			id: model;
			rootType: DocumentGallery.Video;
			properties: ["fileName", "filePath", "duration"];
			sortProperties: ["fileName"];
		}

		delegate: Component{
			Item{
				id: delegateroot;
				width: ListView.view.width;
				height: constants._iSizeXXL;
				MouseArea{
					id: mousearea;
					anchors.fill: parent;
					onClicked: {
						view.currentIndex = index;
						root.__Select(model.filePath, model.fileName);
					}
					onPressAndHold: {
						view.currentIndex = index;
						viewer._Load(model.filePath);
					}
				}

				Column{
					id: col;
					anchors.fill: parent;
					anchors.margins: root.iCellSpacing;
					clip: true;

					Text{
						width: parent.width;
						height: parent.height - ts.height;
						text: model.fileName;
						font.pixelSize: constants._iFontXL;
						elide: Text.ElideMiddle;
						color: constants._cLightColor;
						verticalAlignment: Text.AlignVCenter;
					}
					Text{
						id: ts;
						width: parent.width;
						height: constants._iSizeSmall;
						clip: true;
						text: Util.FormatDuration(model.duration);
						font.pixelSize: constants._iFontMedium;
						elide: Text.ElideRight;
						color: constants._cLightColor;
						verticalAlignment: Text.AlignVCenter;
						horizontalAlignment: Text.AlignRight;
					}
				}

				SeparaterWidget{
					anchors.bottom: parent.bottom;
					anchors.bottomMargin: constants._iSpacingMicro;
					qTarget: col;
					z: 1;
				}
			}
		}
	}

	ScrollDecorator{
		flickableItem: view;
	}

	LayerWidget{
		id: viewer;
		anchors.fill: parent;
		VideoPlayerWidget{
			id: video;
			anchors.centerIn: parent;
			width: Math.min(parent.width, parent.height);
			height: width;
		}

		onClosed:	video._Close();

		function _Load(path)
		{
			video.source = path;
			_Open();
		}
	}

	function __Select(path, name)
	{
		root.sFilePath = path;
		root.sFileName = name;
		root.select(path, name);
	}
}
