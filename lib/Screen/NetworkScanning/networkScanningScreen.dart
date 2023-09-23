import 'dart:io';

import 'package:flutter/material.dart';

class NetworkScanningScreen extends StatefulWidget {
  NetworkScanningScreen({super.key});

  @override
  State<NetworkScanningScreen> createState() => _NetworkScanningScreenState();
}

class _NetworkScanningScreenState extends State<NetworkScanningScreen> {
  final List<String> items = <String>["network 1", "network 2"];

  List<String> connectedDevices = [];

  void scanNetwork() async {
    final String ip = '192.168.100.1'; // Set the base IP of your local network

    for (int i = 1; i <= 255; i++) {
      final String host = '$ip.$i';
      final result = await _ping(host);
      if (result) {
        setState(() {
          connectedDevices.add(host);
          debugPrint("scanNetwork: " + host);
        });
      }
    }
  }

  Future<bool> _ping(String host) async {
    try {
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red,
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(
              height: 56,
            ),
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: SizedBox(
                width: double.infinity,
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Connected To'),
                    Text('STATUS'),
                    ElevatedButton(
                        onPressed: () {
                          scanNetwork();
                        },
                        child: Text('Scan Network'))
                  ],
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: SizedBox(
                  width: double.infinity,
                  child: ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 5.0),
                          child: Card(
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [Text((items[index]))],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
