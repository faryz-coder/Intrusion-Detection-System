// import 'dart:js';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:intrusion_detection_app/Screen/ControlSystem/controlSystemScreen.dart';
import 'package:intrusion_detection_app/Screen/NetworkScanning/networkScanningScreen.dart';

void main() {
  runApp(
    // DevicePreview(
    //   builder: (context) => const MyApp(),
    //   enabled: true,
    // ),
      const MyApp()
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IDsystem',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/second': (context) => const ControlSystemScreen()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: const Color(0xFF35BDCB),
        child: Padding(
          padding: const EdgeInsets.fromLTRB( 8.0, 0, 8.0, 0),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              topLeft: Radius.circular(24),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              onTap: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              // indicatorColor: const Color(0xFF35BDCB),
              selectedItemColor: Colors.amber[800],
              iconSize: 30.0,
              currentIndex: currentPageIndex,
              items: [
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.network_check),
                  icon: Icon(Icons.network_check),
                  label: 'Network',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.offline_bolt),
                  label: 'Appliances',
                ),
              ],
            ),
          ),
        ),
      ),
      body:  <Widget>[
        NetworkScanningScreen(),
        ControlSystemScreen(),
      ][currentPageIndex],
    );
  }
}
