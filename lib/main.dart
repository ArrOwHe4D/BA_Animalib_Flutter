import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flanimalib/AnimalsPage.dart';
import 'package:flanimalib/HomePage.dart';
import 'package:flanimalib/RegionsPage.dart';
import 'package:flanimalib/SettingsPage.dart';
import 'package:flanimalib/SpeciesPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Utils/ColorGenerator.dart';
import 'Utils/DisplayInfo.dart';

Future<void> main() async 
{
  WidgetsFlutterBinding.ensureInitialized();
  
  final List<CameraDescription> deviceCameras;

  if (Platform.isAndroid || Platform.isIOS)
  {
    deviceCameras = await availableCameras();
  }
  else
  {
    deviceCameras = [];
  }

  runApp(MyApp(cameras: deviceCameras));
}

class MyApp extends StatelessWidget 
{
  const MyApp({super.key, required this.cameras});

  final List<CameraDescription> cameras; 

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) 
  {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Color(0xFF10D180), statusBarIconBrightness: Brightness.dark));       

    return MaterialApp
    (      
      theme: ThemeData
      (
        primarySwatch: ColorGenerator.createMaterialColor(const Color(0xFF10D180))
      ),
      home: MainPage(cameras: cameras)
    );
  }
}

class MainPage extends StatefulWidget 
{
  const MainPage({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> 
{  
  int _selectedIndex = 0;   
  double _displayWidth = 0.0;
  double _displayHeight = 0.0; 
  Orientation? _displayOrientation;
  List<Widget>? _pageList;
  
  void onNavigationItemTapped(int index) 
  {
    setState(() 
    {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    _displayWidth = MediaQuery.of(context).size.width;
    _displayHeight = MediaQuery.of(context).size.height; 
    _displayOrientation = MediaQuery.of(context).orientation;

    _pageList = <Widget>
    [
      const HomePage(),
      const AnimalsPage(),
      const SpeciesPage(),
      const RegionsPage(),
      SettingsPage(displayInfo: DisplayInfo(_displayWidth, _displayHeight, _displayOrientation), deviceCameras: widget.cameras)
    ];

    return Scaffold
    (
      backgroundColor: Colors.black,
      body: Center
      (
        child: _pageList?.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar
      (        
        backgroundColor: const Color(0xFF303030),
        selectedItemColor: const Color(0xFF10D180),
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        selectedFontSize: 14.0,
        unselectedFontSize: 12.0,  
        currentIndex: _selectedIndex,
        onTap: onNavigationItemTapped,
        items: const         
        [
          BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/icon_home.png")), label: "Home", backgroundColor: Color(0xFF303030)),
          BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/icon_animals.png")), label: "Animals", backgroundColor: Color(0xFF303030)),
          BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/icon_dna_2.png")), label: "Species", backgroundColor: Color(0xFF303030)),
          BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/icon_globe.png")), label: "Regions", backgroundColor: Color(0xFF303030)),
          BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/icon_settings.png")), label: "Settings", backgroundColor: Color(0xFF303030))
        ]
      )
    );
  }
}
