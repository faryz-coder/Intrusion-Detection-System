import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/notify_services.dart';
import 'devicesModel.dart';

bool isNotify = false;
List<String> lastNotifiedIp = [];
DateTime? lastNotifiedTime;
int id = 0;

class NetworkScanningScreen extends StatefulWidget {
  NetworkScanningScreen({super.key});

  @override
  State<NetworkScanningScreen> createState() => _NetworkScanningScreenState();
}

class _NetworkScanningScreenState extends State<NetworkScanningScreen> {
  final List<String> items = <String>["network 1", "network 2"];

  late Future<Devices> device;
  String enteredName = "";
  bool connected = false;
  late Timer timer;

  Future<Devices> fetchAlbum() async {
    final response =
        await http.get(Uri.parse('http://192.168.100.57:8080/api/data'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      debugPrint("response: Success");
      setState(() {
        connected = true;
      });
      Devices decode = Devices.fromJson(jsonDecode(response.body));
      checkToNotify(decode);
      return Devices.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      setState(() {
        connected = false;
      });
      throw Exception('Failed to load album');
    }
  }

  void checkToNotify(Devices device) {
    String _ip = "";

    device.devices.forEach((element) {
      if (element.allowed == 0) {
        _ip = element.ip;
        // check if ip exist in lastNotifiedIp
        if (!lastNotifiedIp.contains(_ip)) {
          // notify if not exist
          lastNotifiedIp.add(_ip);
          notify(_ip);
          lastNotifiedTime = DateTime.now();
        }
      }
    });

  }

  void resetTimeAfterHalfHour() {
    DateTime now = DateTime.now();
    if (lastNotifiedTime != null) {
      Duration difference = now.difference(lastNotifiedTime!);
      Duration thirtyMin = const Duration(minutes: 30);
      if (difference > thirtyMin) {
        lastNotifiedIp.clear();
      }
    }
  }

  Future<void> updateName(
      String ip, String name, String mac, int status) async {
    final response = await http.get(Uri.parse(
        'http://192.168.100.57:8080/api/update/$ip/$name/$mac/$status'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      debugPrint("response: Success");
      setState(() {
        connected = true;
      });
      fetchAlbum();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      setState(() {
        connected = false;
      });
      throw Exception('Failed to update name');
    }
  }

  Future<void> updateStatus(
      String ip, String name, String mac, int status) async {
    final response = await http.get(Uri.parse(
        'http://192.168.100.57:8080/api/update_status/$ip/$name/$mac/$status'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      debugPrint("response: Success");
      setState(() {
        connected = true;
      });
      removeFromLastIpIfExist(ip);
      fetchAlbum();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      setState(() {
        connected = false;
      });
      throw Exception('Failed to update name');
    }
  }

  void removeFromLastIpIfExist(String ip) {
    if (lastNotifiedIp.isNotEmpty) {
      int location = lastNotifiedIp.indexOf(ip);
      lastNotifiedIp.removeAt(location);
    }
  }

  @override
  void initState() {
    super.initState();
    device = fetchAlbum();
    timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        device = fetchAlbum(); /**/
        debugPrint("timer"); /*Future*/
      });
    });
  }

  @override
  void dispose() {
    debugPrint("onDispose");
    timer.cancel();
    super.dispose();
  }

  Future<void> listNetwork() async {
    Devices device = await fetchAlbum();
    debugPrint(device.devices.elementAt(1).ip);
  }

  void notify(String ip) {
    NotificationService().showNotification(
        id: id,
        title: "Intrusion Detection",
        body: 'Unauthorized ip detected :: $ip');
    id += 1;
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
                    Text('STATUS'),
                    connected == true
                        ? const Text('CONNECTED')
                        : const Text('DISCONNECT'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: SizedBox(
                  width: double.infinity,
                  child: FutureBuilder<Devices>(
                    future: device,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: snapshot.data?.devices.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 5.0),
                                child: Card(
                                  elevation: 3,
                                  clipBehavior: Clip.hardEdge,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: InkWell(
                                      splashColor: Colors.blue.withAlpha(30),
                                      onLongPress: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: const Text("Enter Name"),
                                          content: TextField(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: '',
                                            ),
                                            onChanged: (value) {
                                              enteredName = value;
                                            },
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                enteredName = "";
                                                Navigator.pop(
                                                    context, 'Cancel');
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                updateName(
                                                    snapshot.data!
                                                        .devices[index].ip,
                                                    enteredName,
                                                    snapshot.data!
                                                        .devices[index].mac,
                                                    snapshot
                                                        .data!
                                                        .devices[index]
                                                        .allowed);
                                                Navigator.pop(context, 'OK');
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                snapshot.data!.devices[index]
                                                        .name.isNotEmpty
                                                    ? Text(
                                                        "Name: ${snapshot.data!.devices[index].name}")
                                                    : const SizedBox(),
                                                Text(
                                                    "Ip: ${snapshot.data!.devices[index].ip}"),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    updateStatus(
                                                        snapshot.data!
                                                            .devices[index].ip,
                                                        snapshot
                                                            .data!
                                                            .devices[index]
                                                            .name,
                                                        snapshot.data!
                                                            .devices[index].mac,
                                                        1);
                                                  },
                                                  icon: Icon(
                                                    Icons.check_circle,
                                                    color: snapshot
                                                                .data!
                                                                .devices[index]
                                                                .allowed ==
                                                            1
                                                        ? Colors.green
                                                        : Colors.grey,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    updateStatus(
                                                        snapshot.data!
                                                            .devices[index].ip,
                                                        snapshot
                                                            .data!
                                                            .devices[index]
                                                            .name,
                                                        snapshot.data!
                                                            .devices[index].mac,
                                                        0);
                                                  },
                                                  icon: Icon(
                                                    Icons.cancel_outlined,
                                                    color: snapshot
                                                                .data!
                                                                .devices[index]
                                                                .allowed ==
                                                            0
                                                        ? Colors.red
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
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
