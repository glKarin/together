import QtQuick 1.1
import com.nokia.meego 1.1
import QtMobility.gallery 1.1

Item{
	id: root;
	objectName: "idImageChooserWidget";

	property int iCellWidth: 150;
	property int iCellSpacing: 0;
	property string sFilePath;
	property string sFileName;
	property string sFilter: "";

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

	GridView{
		id: view;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.horizontalCenter: parent.horizontalCenter;
		width: Math.floor(root.width / cellWidth) * cellWidth;
		cellWidth: root.iCellWidth;
		cellHeight: cellWidth;
		clip: true;

		model: DocumentGalleryModel{
			id: model;
			rootType: DocumentGallery.Image;
			properties: ["fileName", "filePath", "url"];
			sortProperties: ["fileName"];
			filter: GalleryWildcardFilter {
				property: "fileName";
				value: root.sFilter;
			}
		}

		delegate: Component{
			Item{
				id: delegateroot;
				width: GridView.view.cellWidth;
				height: GridView.view.cellHeight;
				Image{
					id: thumbnail;
					anchors.fill: parent;
					anchors.margins: root.iCellSpacing;
					source: model.url;
					sourceSize.width: delegateroot.width - root.iCellSpacing * 2;
					fillMode: Image.PreserveAspectCrop;
					clip: true;
					asynchronous: true;

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

					Text{
						anchors.fill: parent;
						z: 1;
						horizontalAlignment: Text.AlignHCenter;
						verticalAlignment: Text.AlignVCenter;
						visible: thumbnail.status !== Image.Ready;
						wrapMode: Text.WrapAnywhere;
						font.pixelSize: constants._iFontLarge;
						color: constants._cLightColor;
						clip: true;
						text: {
							switch(thumbnail.status)
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
					}
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
		ImageViewerWidget{
			id: image;
			anchors.centerIn: parent;
			width: Math.min(parent.width, parent.height);
			height: width;
			cTextColor: constants._cLightColor;
			onTextClicked: {
				viewer._Close();
			}
		}

		onClosed:	image.source = "";

		function _Load(path)
		{
			image.source = path;
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
