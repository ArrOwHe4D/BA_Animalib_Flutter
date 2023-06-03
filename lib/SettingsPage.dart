import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:camera/camera.dart';
import 'package:device_info/device_info.dart';
import 'package:flanimalib/Widgets/customcardview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barometer_plugin/flutter_barometer.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'Utils/DisplayInfo.dart';

class SettingsPage extends StatefulWidget 
{
  const SettingsPage({Key? key, required this.displayInfo, required this.deviceCameras}) : super(key: key);

  final List<CameraDescription> deviceCameras;
  final DisplayInfo displayInfo;

  @override State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> 
{
    //Battery Info
    final Battery _battery = Battery();    
    int _batteryLevel = 0;    
    BatteryState? _batteryState;
    String? _batteryStateString; 
    StreamSubscription<BatteryState>? _batteryStateSubscription;

    //Display Info
    late DisplayInfo _displayInfo;
    String? _displayOrientationString;

    //Device Info
    final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo? _androidDeviceInfo;
    String? _deviceInfoPlatform;
    String? _deviceInfoType;
    String? _deviceInfoIdiom;
    String? _deviceInfoModel;
    String? _deviceInfoManufacturer;
    String? _deviceInfoName;
    String? _deviceInfoOsVersion;    

    //Camera
    late List<CameraDescription> _deviceCameras;
    bool _flashLightActive = false;        

    //Location    
    Position? _currentLocation;
    double?   _currentLocationLongitude;
    double?   _currentLocationLatitude;    
    double?   _locationByAddressLongitude;
    double?   _locationByAddressLatitude;
    String?   _addressByLocation;

    //Sensors
    bool          _gyroscopeActive = false;    
    double?       _gyroscopeX;
    double?       _gyroscopeY;
    double?       _gyroscopeZ;

    bool          _barometerActive = false;
    double?       _barometerHpa;
    bool          _accelerometerActive = false;
    double?       _accelerometerX;
    double?       _accelerometerY;
    double?       _accelerometerZ;

    bool          _magnetometerActive = false;
    double?       _magnetometerX;
    double?       _magnetometerY;
    double?       _magnetometerZ;
    CompassEvent? _compassReading;
    
    late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
    late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
    late StreamSubscription<MagnetometerEvent> _magnetometerSubscription;

    @override
    void initState()
    {
      super.initState();

      //Battery Info
      _battery.batteryState.then(updateBatteryState);
      _batteryStateSubscription = _battery.onBatteryStateChanged.listen(updateBatteryState);   
      _battery.batteryLevel.then((batteryLevel) => _batteryLevel = batteryLevel);

      //Display Info
      _displayInfo = widget.displayInfo;
      _displayOrientationString = updateDisplayOrientation(); 

      //Camera
      _deviceCameras = widget.deviceCameras;
    }

    @override 
    void didChangeDependencies()
    {
      super.didChangeDependencies();
      updateDeviceInfo();
    }

    Future<void> updateDeviceInfo() async
    {
      _androidDeviceInfo = await _deviceInfo.androidInfo;            

      if (Platform.isAndroid)
      {        
        _deviceInfoPlatform = "Android";             
        _deviceInfoIdiom = "N/A"; //Could not find idiom data in device_info package
        _deviceInfoModel = _androidDeviceInfo?.model;
        _deviceInfoManufacturer = _androidDeviceInfo?.manufacturer;
        _deviceInfoName = "N/A"; //Could not find device name in device_info package
        _deviceInfoOsVersion = _androidDeviceInfo?.version.release;
        
        if (_androidDeviceInfo?.isPhysicalDevice != null)
        {
          _deviceInfoType = _androidDeviceInfo?.isPhysicalDevice == true ? "Physical" : "Virtual";
        }
        else 
        {
          _deviceInfoType = "Unknown";
        }
      }    
    }

    String updateDisplayOrientation()
    {
      switch (_displayInfo.orientation)
      {
        case Orientation.landscape:
        {
          return "Landscape";
        }
        case Orientation.portrait:
        {
          return "Portrait";
        }
        default:
        {
          return "Unknown";
        }
      }
    }

    void updateBatteryState(BatteryState state)
    {
      if (_batteryState == state) return;
      setState(() 
      {
        _batteryState = state;

        switch (state)
        {
          case BatteryState.charging:
          {
            _batteryStateString = "Charging";
            break;
          }
          case BatteryState.discharging:
          {
            _batteryStateString = "Discharging";
            break;
          }
          case BatteryState.full:
          {
            _batteryStateString = "Full";
            break;
          }
          case BatteryState.unknown:
          {
            _batteryStateString = "Unknown";
            break;
          }
          default: 
          {
            _batteryStateString = "Unknown";
          }
        }
      });
    }

    void takePicture() async
    {
        Stopwatch stopWatch = Stopwatch()..start();

        final mediaPicker = ImagePicker();
        final capturedImage = await mediaPicker.pickImage(source: ImageSource.camera);                           

        final Directory? storageDirectory = await getExternalStorageDirectory();        
        final String destinationPath = path.join(storageDirectory!.path, 'animalib_image_${DateTime.now().millisecondsSinceEpoch.toString()}.jpg');            

        capturedImage!.saveTo(destinationPath);            

        stopWatch.stop();            

        Fluttertoast.showToast(msg: 'Task completed in: ${stopWatch.elapsedMilliseconds} ms', toastLength: Toast.LENGTH_LONG);    
    }

    void toggleFlashlight() async 
    {
      CameraController cameraController = CameraController(_deviceCameras[0], ResolutionPreset.ultraHigh);
      await cameraController.initialize();   

      if (!_flashLightActive)
      {
        setState(() { _flashLightActive = true; });     
        await cameraController.setFlashMode(FlashMode.torch);
      }
      else 
      {
        setState(() { _flashLightActive = false; });        
        await cameraController.setFlashMode(FlashMode.off);
      }
    }

    void getCurrentLocation() async
    {
      PermissionStatus permissionStatus = await Permission.location.request();

      if (permissionStatus == PermissionStatus.granted)
      {
        _currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        setState(() 
        {
          _currentLocationLongitude = _currentLocation?.longitude;
          _currentLocationLatitude = _currentLocation?.latitude;          
        });        
      }
      else 
      {
        Fluttertoast.showToast(msg: "Could not retrieve location data, ensure that location services are activated!", toastLength: Toast.LENGTH_LONG);
      }
    }

    void getAddressByLocation(double longitude, double latitude) async
    {
      List<Placemark> placemarkResults = await GeocodingPlatform.instance.placemarkFromCoordinates(latitude, longitude);

      Placemark result = placemarkResults.first;

      setState(() 
      {
        _addressByLocation = '${result.street}, ${result.postalCode} ${result.locality}';
      });
    }

    void getLocationByAddress(String address) async
    {
      List<Location> locationResult = await GeocodingPlatform.instance.locationFromAddress(address);

      setState(() 
      {
        _locationByAddressLongitude = locationResult.first.longitude;
        _locationByAddressLatitude = locationResult.first.latitude;        
      });
    }

    void toggleGyroscope()
    {      
      setState(() { _gyroscopeActive = !_gyroscopeActive; });
      
      if (_gyroscopeActive)
      {
        _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) 
        { 
          setState(() 
          {
            _gyroscopeX = event.x;
            _gyroscopeY = event.y;
            _gyroscopeZ = event.z;          
          });
        });
      }
      else
      {
        _gyroscopeSubscription.cancel();                  
      }
    }

    void toggleBarometer() 
    {
      FlutterBarometer.currentPressureEvent.listen((event) 
      {
        setState(() 
        {
          _barometerHpa = event.hectpascal;          
        });
      });
    }

    void toggleAccelerometer()
    {
      setState(() { _accelerometerActive = !_accelerometerActive; });
      
      if (_accelerometerActive)
      {
        _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) 
        { 
          setState(() 
          {
            _accelerometerX = event.x;
            _accelerometerY = event.y;
            _accelerometerZ = event.z;          
          });
        });
      }
      else
      {
        _accelerometerSubscription.cancel();                        
      }
    }

    void toggleMagnetometer() 
    {
      setState(() { _magnetometerActive = !_magnetometerActive; });

      if (_magnetometerActive)
      {
        _magnetometerSubscription = magnetometerEvents.listen((MagnetometerEvent event) 
        {
          setState(() 
          {
            _magnetometerX = event.x;
            _magnetometerY = event.y;
            _magnetometerZ = event.z;       
          });
        });
      }
      else 
      {
        _magnetometerSubscription.cancel();
      }
    }

    void readCompass() async
    {
      CompassEvent tmp = await FlutterCompass.events!.first;

      setState(() 
      {
        _compassReading = tmp;
      });
    }

    @override
    Widget build(BuildContext context) 
    {
      return Center
      (
        child: Column
        (        
          children: 
          [
            const SizedBox(height: 30),
            Row
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children: 
              [
                Image.asset('images/icon_title_settings.png', width: 40, height: 40),
                const SizedBox(width: 5),
                const Text('Settings', style: TextStyle(fontSize: 40.0, color: Colors.white))
              ]
            ),
            CustomCardView
            (
              child: Container
              (
                height: MediaQuery.of(context).size.height * 0.795,
                child: SingleChildScrollView
                (
                  child: Column
                  (       
                    crossAxisAlignment: CrossAxisAlignment.start,             
                    children: 
                    [
                      Row(children: [ Image.asset('images/icon_battery.png', width: 40, height: 40), Text('Battery Info', style: TextStyle(fontSize: 24.0, color: Colors.greenAccent[400])) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Charge Level: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_batteryLevel%', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Status: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_batteryStateString', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      const Row(children: [ Text('Power Source: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('N/A', style: TextStyle(fontSize: 14, color: Colors.red)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ Image.asset('images/icon_screen.png', width: 40, height: 40), Text('Display Info', style: TextStyle(fontSize: 24.0, color: Colors.greenAccent[400])) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Width: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('${_displayInfo.width} Pixels', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Height: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('${_displayInfo.height}  Pixels', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Orientation: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_displayOrientationString', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      const Row(children: [ Text('Rotation: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('N/A', style: TextStyle(fontSize: 14, color: Colors.red)) ]),
                      const SizedBox(height: 10),
                      const Row(children: [ Text('Refresh Rate: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('N/A', style: TextStyle(fontSize: 14, color: Colors.red)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ Image.asset('images/icon_device.png', width: 40, height: 40), Text('Device Info', style: TextStyle(fontSize: 24.0, color: Colors.greenAccent[400])) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Platform: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_deviceInfoPlatform', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('OS Version: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_deviceInfoOsVersion', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Type: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_deviceInfoType', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Idiom: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_deviceInfoIdiom', style: const TextStyle(fontSize: 14, color: Colors.red)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Model: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_deviceInfoModel', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Manufacturer: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_deviceInfoManufacturer', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Name: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_deviceInfoName', style: const TextStyle(fontSize: 14, color: Colors.red)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ Image.asset('images/icon_camera.png', width: 40, height: 40), Text('Camera', style: TextStyle(fontSize: 24.0, color: Colors.greenAccent[400])) ]),
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [ ElevatedButton(onPressed: () {takePicture();}, child: const Text('Take Picture', style: TextStyle(color: Colors.white))) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Flashlight: ', style: TextStyle(fontSize: 14, color: Colors.white)), Switch(value: _flashLightActive, onChanged: (value){toggleFlashlight();}) ]), 
                      const SizedBox(height: 10),
                      Row(children: [ Image.asset('images/icon_title_regions.png', width: 40, height: 40), Text('Location', style: TextStyle(fontSize: 24.0, color: Colors.greenAccent[400])) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Current Location Lat: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_currentLocationLatitude', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Current Location Lon: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_currentLocationLongitude', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [ ElevatedButton(onPressed: getCurrentLocation, child: const Text('Get Current Location', style: TextStyle(color: Colors.white))) ]),
                      const SizedBox(height: 10),
                      const Row(children: [ Text('Address: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('Steinmüllerallee 1, 51643 Gummersbach', style: TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Latitude: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_locationByAddressLatitude', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Longitude: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_locationByAddressLongitude', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [ ElevatedButton(onPressed: () { getLocationByAddress('Steinmüllerallee 1, 51643 Gummersbach'); }, child: const Text('Get TH-Köln Location', style: TextStyle(color: Colors.white))) ]),
                      const SizedBox(height: 10),
                      const Row(children: [ Text('Address Location: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('(Lon: 7.5618184, Lat: 51.0230325)', style: TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(children: [ const Text('Address: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text('$_addressByLocation', style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [ ElevatedButton(onPressed: () { getAddressByLocation(7.5618184, 51.0230325); }, child: const Text('Get TH-Köln Address', style: TextStyle(color: Colors.white))) ]),
                      const SizedBox(height: 10),
                      Row(children: [ Image.asset('images/icon_sensors.png', width: 40, height: 40), Text('Sensors', style: TextStyle(fontSize: 24.0, color: Colors.greenAccent[400])) ]),
                      const SizedBox(height: 10),
                      const Text('Gyroscope: ', style: TextStyle(fontSize: 14, color: Colors.white)),
                      Text('X: $_gyroscopeX, Y: $_gyroscopeY, Z: $_gyroscopeZ', style: TextStyle(fontSize: 14, color: Colors.greenAccent[400])),
                      Switch(value: _gyroscopeActive, onChanged: (value){ toggleGyroscope(); }),
                      const SizedBox(height: 10),
                      const Text('Barometer: ', style: TextStyle(fontSize: 14, color: Colors.white)),
                      Text('$_barometerHpa hPa', style: TextStyle(fontSize: 14, color: Colors.greenAccent[400])),
                      Switch(value: _barometerActive, onChanged: (value){ toggleBarometer(); }),
                      const SizedBox(height: 10),
                      const Text('Accelerometer: ', style: TextStyle(fontSize: 14, color: Colors.white)),
                      Text('X: $_accelerometerX, Y: $_accelerometerY, Z: $_accelerometerZ', style: TextStyle(fontSize: 14, color: Colors.greenAccent[400])),
                      Switch(value: _accelerometerActive, onChanged: (value){ toggleAccelerometer(); }),
                      const SizedBox(height: 10),
                      const Text('Magnetometer: ', style: TextStyle(fontSize: 14, color: Colors.white)),
                      Text('X: $_magnetometerX, Y: $_magnetometerY, Z: $_magnetometerZ', style: TextStyle(fontSize: 14, color: Colors.greenAccent[400])),
                      Switch(value: _magnetometerActive, onChanged: (value){ toggleMagnetometer(); }),
                      const SizedBox(height: 10),
                      const Text('Compass: ', style: TextStyle(fontSize: 14, color: Colors.white)),
                      Text('$_compassReading', style: TextStyle(fontSize: 14, color: Colors.greenAccent[400])),
                      ElevatedButton(onPressed: readCompass, child: const Text('Read Compass', style: TextStyle(color: Colors.white)))                     
                    ]
                  ) 
                ) 
              )
            )
          ]
        )
      );
    }

    @override
    void dispose() 
    {
      super.dispose();
      if (_batteryStateSubscription != null)
      {
        _batteryStateSubscription!.cancel();        
      }   
      if (_gyroscopeSubscription != null)
      {
        _gyroscopeSubscription!.cancel();
      }   
      if (_accelerometerSubscription != null)
      {
        _accelerometerSubscription!.cancel();
      }
      if (_magnetometerSubscription != null)
      {
        _magnetometerSubscription!.cancel();
      }      
    }
}