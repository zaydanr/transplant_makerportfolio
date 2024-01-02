import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:trans_plant/sensors.dart';
import 'dashboard.dart';
import 'camera.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>{

  int _SelectedIndex = 0;
  static  List<Widget> _widgetOptions = <Widget>[
    WeatherWidget(),
    SensorsPage(),
    Camera(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            gap: 8,
            iconSize: 19,
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.dashboard,
                text: 'Dashboard',
                ),
              GButton(
                icon: Icons.sensors,
                text: 'Sensors',
                ),
              GButton(
                icon: Icons.photo_camera,
                text: 'Camera',
                
                ),

            ],
            selectedIndex: _SelectedIndex,
            onTabChange: (index){
              setState(() {
                _SelectedIndex = index;
              });
            }
          ),
        ),
      ),
        body: Center(child: _widgetOptions.elementAt(_SelectedIndex)),
      );
  }
}