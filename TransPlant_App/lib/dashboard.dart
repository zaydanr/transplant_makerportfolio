import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'mqtt_service.dart'; // Import the MQTT service file

class WeatherWidget extends StatefulWidget {
  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final MqttService mqttService = MqttService(); // Start the MQTT service
  String currentConditions = ''; // Store API data for current conditions
  Color currentConditionsColor = Colors.white;
  String temperature = ''; // Store API data for temperature
  String humidity = ''; // Store API data for humidity
  String wind = ''; // Store API data for wind
  String precipitationAmount = ''; // Store API data for precipitation amountS

  int notificationInterval = 1; // Default notification interval in days

  bool isAutonomous = false; // Variable to track the autonomy state

  @override
  void initState() {
    super.initState();
    mqttService.connect('64c14253811ec75105c1948a', 'QuRHxlbi8RDbkv7Nkq77N3Ps');
    fetchWeatherData();
    // Initialize the state of the switch
    isAutonomous = false;
  }

  @override
  void dispose() {
    mqttService.disconnect(); // Disconnect from the MQTT broker when the widget is disposed
    super.dispose();
  }

  Future<void> fetchWeatherData() async {
    // Fetch weather data from API
    String apiUrl = 'http://api.weatherapi.com/v1/current.json?key=4ccf6305a692493699f00248230308&q=Rockville&aqi=no';
    var response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      currentConditions = data['current']['condition']['text'];
      temperature = data['current']['temp_f'].toString() + '°F';
      humidity = data['current']['humidity'].toString() + '%';
      wind = data['current']['wind_mph'].toString() + ' mph';
      precipitationAmount = data['current']['precip_in'].toString() + ' in';

      // Update the currentConditionsColor based on the conditions (customize as needed)
      if (currentConditions.contains('Rain')) {
        currentConditionsColor = Colors.blue;
      } else if (currentConditions.contains('Cloud')) {
        currentConditionsColor = Colors.grey;
      } else if (currentConditions.contains('Clear')) {
        currentConditionsColor = Colors.yellow;
      } else {
        currentConditionsColor = Colors.white;
      }

      setState(() {}); // Trigger a rebuild with fetched data
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  width: size.width,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 167, 241, 145),
                        Color.fromARGB(193, 172, 231, 145),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0.2, 1.2],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        Text(
                          'Weather in Shady Grove, MD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildWeatherDataRow(
                          currentConditionsIcon(),
                          'Current Conditions',
                          currentConditions,
                        ),
                        _buildWeatherDataRow(Icons.thermostat, 'Temperature', temperature),
                        _buildWeatherDataRow(Icons.opacity, 'Humidity', humidity),
                        _buildWeatherDataRow(Icons.air, 'Wind', wind),
                        _buildWeatherDataRow(Icons.cloud, 'Precipitation', precipitationAmount),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        mqttService.publishMessage('light_on');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 89, 212, 109),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text('Lamp On'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        mqttService.publishMessage('light_off');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 89, 212, 109),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text('Lamp Off'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        mqttService.publishMessage('pump_on');
                        Timer(Duration(seconds: 20), () {
                          mqttService.publishMessage('pump_off');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 89, 212, 109),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text('Quick Water'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Manual',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Switch(
                      value: isAutonomous,
                      onChanged: (value) {
                        setState(() {
                          isAutonomous = value;
                          mqttService.publishMessage(isAutonomous ? 'auto_1' : 'auto_0');
                        });
                      },
                      activeTrackColor: Color.fromARGB(255, 89, 212, 109),
                      activeColor: Colors.white,
                    ),
                    Text(
                      'Autonomous',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDataRow(
    IconData icon,
    String title,
    String value, {
    Color textColor = Colors.white,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Icon(icon, color: textColor, size: 32),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData currentConditionsIcon() {
    // Map the current conditions to appropriate icons
    if (currentConditions.contains('Sunny')) {
      return Icons.wb_sunny;
    } else if (currentConditions.contains('Cloud')) {
      return Icons.cloud;
    } else if (currentConditions.contains('Rain')) {
      return Icons.grain;
    } else if (currentConditions.contains('Clear')) {
      return Icons.wb_sunny;
    } else {
      return Icons.cloud; // Default icon for unknown conditions
    }
  }
}
