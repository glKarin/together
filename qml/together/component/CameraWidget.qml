import QtQuick 1.1
import com.nokia.meego 1.1
import QtMultimediaKit 1.1

Item{
	id: root;
	property string previewImage;
	property int eOrientation: 0;
	property alias cameraItem: camera;
	property variant __settingsDialog: null;
	property variant __previewDialog: null;
	property int __rotationAnimDuration: 800;
	signal captured(string previewImage);

	Camera {
		id: camera;
		property url flashModeIcon: "image://theme/icon-m-camera-flash-auto-screen";
		property url exposureModeIcon: "image://theme/icon-m-camera-scene-auto-screen";
		property real maxZoomFactory: Math.min(4.0, camera.maximumDigitalZoom);

		anchors.fill: parent;
		focus: visible;

		captureResolution: screen.displayWidth + "x" + screen.displayHeight;
		exposureMode: Camera.ExposureAuto;
		flashMode: Camera.FlashOff;
		whiteBalanceMode: Camera.WhiteBalanceAuto;

		onImageSaved: {
			console.log("[Qml]: Capture image -> " + path);
			root.previewImage = path;
			__OpenPreviewImage(path);
		}
		onImageCaptured: {
			root.previewImage = "";
			//k __OpenPreviewImage(preview);
		}
		onCaptureFailed: {
			console.log("[Qml]: Camera capture image error -> " + message);
		}

		PinchArea{
			anchors.fill: parent;
			onPinchUpdated: {
				var delta = pinch.scale - pinch.previousScale;
				var f = camera.digitalZoom;
				if(camera.digitalZoom + delta <= 0.0)
				f = 0.1;
				else if(camera.digitalZoom + delta > camera.maxZoomFactory)
				f = camera.maxZoomFactory;
				else
				f += delta;
				camera.setDigitalZoom(f);
			}
		}

		MouseArea {
			anchors.fill: parent

			onClicked: {
				if (camera.lockStatus === Camera.Unlocked)
				camera.searchAndLock();
				else
				camera.unlock();
			}
		}
		onError:{
			if(error !== Camera.NoError){
				console.log("[Qml]: " + error + " -> " + errorString);
			}
		}
	}

	Image {
		id: captureImage;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.right: parent.right;
		anchors.rightMargin: constants._iSpacingSuper;
		z: 1;
		clip: true;
		source: "image://theme/meegotouch-camera-shutter-key-background";
		Image {
			anchors.centerIn: parent;
			source: "image://theme/icon-m-camera-shutter";
			smooth: true;
			rotation: root.eOrientation !== 0 ? -90 : 0;
			Behavior on rotation{
				NumberAnimation{
					duration: root.__rotationAnimDuration;
				}
			}
		}
		MouseArea{
			anchors.fill: parent;
			onClicked: {
				root.previewImage = "";
				camera.captureImage();
			}
		}
	}

	Image {
		id: controlsImage;
		anchors.bottom: parent.bottom;
		anchors.bottomMargin: constants._iSpacingLarge;
		anchors.horizontalCenter: captureImage.horizontalCenter;
		z: 1;
		source: settingmousearea.pressed ? "image://theme/meegotouch-camera-settings-indicators-background-pressed" : "image://theme/meegotouch-camera-settings-indicators-background";
		clip: true;

		Column {
			anchors.centerIn: parent;
			spacing: constants._iSpacingTooBig;

			Image {
				anchors.horizontalCenter: parent.horizontalCenter;
				source: camera.flashModeIcon;
				rotation: root.eOrientation !== 0 ? -90 : 0;
				smooth: true;
				Behavior on rotation{
					NumberAnimation{
						duration: root.__rotationAnimDuration;
					}
				}
			}
			Image {
				anchors.horizontalCenter: parent.horizontalCenter;
				source: camera.exposureModeIcon;
				rotation: root.eOrientation !== 0 ? -90 : 0;
				smooth: true;
				Behavior on rotation{
					NumberAnimation{
						duration: root.__rotationAnimDuration;
					}
				}
			}
		}

		MouseArea {
			id: settingmousearea;
			anchors.fill: parent

			onClicked: {
				__OpenSettingsDialog();
			}
		}
	}
	Item{
		id: zoombar;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: parent.top;
		width: parent.width;
		height: constants._iSizeLarge;
		clip: true;
		opacity: 0.6;

		ProgressBar{
			id: progressbar;
			anchors.centerIn: parent;
			width: parent.width / 3 * 2;
			minimumValue: 1;
			maximumValue: camera.maxZoomFactory;
			value: camera.digitalZoom;
		}

		MouseArea{
			id: mousearea;
			anchors.top: parent.top;
			anchors.bottom: parent.bottom;
			anchors.left: progressbar.left;
			anchors.right: progressbar.right;
			onPressed: {
				zoombar._SetPercent(mouse.x / mousearea.width);
			}
			onPositionChanged: {
				if(mousearea.pressed)
				zoombar._SetPercent(mouse.x / mousearea.width);
			}
		}

		//! End of File
		function _SetPercent(p)
		{
			camera.setDigitalZoom((progressbar.maximumValue - progressbar.minimumValue) * p + progressbar.minimumValue);
		}

	}

	function __OpenSettingsDialog()
	{
		if(!root.__settingsDialog)
		{
			var prop = {
				camera: camera,
			};
			root.__settingsDialog = controlcomp.createObject(root, prop);
		}
		root.__settingsDialog._Open();
	}

	function __OpenPreviewImage(path)
	{
		if(!root.__previewDialog)
		{
			root.__previewDialog = previewcomp.createObject(root);
			root.__previewDialog.done.connect(function(){
				if(root.previewImage)
				root.captured(root.previewImage)
			});
		}
		root.__previewDialog._Load(path);
	}

	Component{
		id: controlcomp;

		LayerWidget{
			id: diagroot;
			property Camera camera

			anchors.fill: parent;
			objectName: "idCameraSettingsDialog";
			cForegroundColor: constants._cDarkColor;

			Flickable{
				id: flick;
				anchors.fill: parent;
				contentWidth: width;
				contentHeight: col.height;
				clip: true;
				rotation: root.eOrientation !== 0 ? -90 : 0;

				Column{
					id: col;
					width: parent.width;
					SectionWidget{
						anchors.horizontalCenter: parent.horizontalCenter;
						sText: qsTr("Flash mode");
						cTextColor: constants._cLightColor;
						cColor: constants._cLightColor;
					}
					Grid{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;
						columns: 4;
						spacing: constants._iSpacingSuper;
						Repeater{
							model: [
								{
									source: "image://theme/icon-m-camera-flash-auto",
									label: qsTr("Automatic"),
									value: Camera.FlashAuto,
								},
								{
									source: "image://theme/icon-m-camera-flash-always",
									label: qsTr("On"),
									value: Camera.FlashOn,
								},
								{
									source: "image://theme/icon-m-camera-flash-off",
									label: qsTr("Off"),
									value: Camera.FlashOff,
								},
								{
									source: "image://theme/icon-m-camera-flash-red-eye",
									label: qsTr("Red eye"),
									value: Camera.FlashRedEyeReduction,
								},
							];
							delegate: Component{
								ImageButtonWidget{
									source: diagroot.camera.flashMode == modelData.value ? modelData.source + "-selected" : modelData.source + "";
									text: modelData.label;
									color: constants._cLightColor;
									onClicked: {
										camera.flashMode = modelData.value;
										camera.flashModeIcon = modelData.source + "-screen";
									}
								}
							}
						}
					}

					SectionWidget{
						anchors.horizontalCenter: parent.horizontalCenter;
						sText: qsTr("Exposure mode");
						cTextColor: constants._cLightColor;
						cColor: constants._cLightColor;
					}
					Grid{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;
						columns: 4;
						spacing: constants._iSpacingSuper;
						Repeater{
							model: [
								{
									source: "image://theme/icon-m-camera-scene-auto",
									label: qsTr("Automatic"),
									value: Camera.ExposureAuto
								},
								{
									source: "image://theme/icon-m-camera-scene-portrait",
									label: qsTr("Portrait"),
									value: Camera.ExposurePortrait,
								},
								{
									source: "image://theme/icon-m-camera-night",
									label: qsTr("Night"),
									value: Camera.ExposureNight,
								},
								{
									source: "image://theme/icon-m-camera-scene-sports",
									label: qsTr("Sports"),
									value: Camera.ExposureSports,
								},
							];
							delegate: Component{
								ImageButtonWidget{
									source: diagroot.camera.exposureMode == modelData.value ? modelData.source + "-selected" : modelData.source + "";
									text: modelData.label;
									color: constants._cLightColor;
									onClicked: {
										camera.exposureMode = modelData.value;
										camera.exposureModeIcon = modelData.source + "-screen";
									}
								}
							}
						}
					}

					SectionWidget{
						anchors.horizontalCenter: parent.horizontalCenter;
						sText: qsTr("White balance mode");
						cTextColor: constants._cLightColor;
						cColor: constants._cLightColor;
					}
					Grid{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;
						columns: 4;
						spacing: constants._iSpacingSuper;
						Repeater{
							model: [
								{
									source: "image://theme/icon-m-camera-whitebalance-auto",
									label: qsTr("Automatic"),
									value: Camera.WhiteBalanceAuto,
								},
								{
									source: "image://theme/icon-m-camera-whitebalance-sunny",
									label: qsTr("Sunny"),
									value: Camera.WhiteBalanceSunlight,
								},
								{
									source: "image://theme/icon-m-camera-whitebalance-cloudy",
									label: qsTr("Cloudy"),
									value: Camera.WhiteBalanceCloudy,
								},
								{
									source: "image://theme/icon-m-camera-whitebalance-fluorescent",
									label: qsTr("Fluorescent"),
									value: Camera.WhiteBalanceFluorescent,
								},
								{
									source: "image://theme/icon-m-camera-whitebalance-tungsten",
									label: qsTr("Tungsten"),
									value: Camera.WhiteBalanceTungsten,
								},
							];
							delegate: Component{
								ImageButtonWidget{
									source: diagroot.camera.whiteBalanceMode == modelData.value ? modelData.source + "-selected" : modelData.source + "";
									text: modelData.label;
									color: constants._cLightColor;
									onClicked: {
										camera.whiteBalanceMode = modelData.value;
									}
								}
							}
						}
					}
				}
			}

			ScrollDecorator{
				rotation: root.eOrientation !== 0 ? -90 : 0;
				flickableItem: flick;
			}
		}
	}

	Component{
		id: previewcomp;

		LayerWidget{
			id: previewroot;
			property alias previewImage: image.source;
			signal done();

			anchors.fill: parent;
			z: 50;
			objectName: "idCameraPreviewDialog";
			eContentSizePolicy: 2;

			ImageViewerWidget{
				id: image;
				anchors.fill: parent;
				cTextColor: constants._cLightColor;
			}
			Column{
				anchors.verticalCenter: parent.verticalCenter;
				anchors.right: parent.right;
				anchors.rightMargin: constants._iSpacingSuper;
				spacing: constants._iSpacingSuper * 2;
				width: constants._iSizeXL;
				opacity: 0.6;
				z: 1;
				IconWidget{
					iconId: "toolbar-done";
					width: parent.width;
					height: width;
					onClicked: {
						previewroot.done();
					}
					rotation: root.eOrientation !== 0 ? -90 : 0;
					Behavior on rotation{
						NumberAnimation{
							duration: root.__rotationAnimDuration;
						}
					}
				}
				IconWidget{
					iconId: "toolbar-close";
					width: parent.width;
					height: width;
					rotation: root.eOrientation !== 0 ? -90 : 0;
					Behavior on rotation{
						NumberAnimation{
							duration: root.__rotationAnimDuration;
						}
					}
					onClicked: {
						image.source = "";
						previewroot._Close();
					}
				}
			}
			function _Load(path)
			{
				image.source = path;
				previewroot._Open();
			}
		}
	}
}
