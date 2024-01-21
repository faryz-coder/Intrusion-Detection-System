import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'appliancesModel.dart';

class ControlSystemScreen extends StatefulWidget {
  const ControlSystemScreen({super.key});

  @override
  State<ControlSystemScreen> createState() => _ControlSystemScreenState();
}

class _ControlSystemScreenState extends State<ControlSystemScreen> {
  late Future<Appliances> appliances;
  String enteredServerIp = "";
  bool light0 = true;
  bool light1 = true;
  bool connected = false;
  late SharedPreferences prefs;
  late Timer timer;
  late String serverIp;

  Future<void> getServerIp() async {
    prefs = await SharedPreferences.getInstance();
    serverIp = prefs.getString('serverIp') ?? '192.168.100.57:8080';
  }

  Future<void> setServerIp(String ip) async {
    await prefs.setString('serverIp', ip);
    getServerIp();
  }

  Future<Appliances> fetchListAppliances() async {
    final response = await http
        .get(Uri.parse('http://$serverIp/api/appliances/list'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      debugPrint("response: Success");
      setState(() {
        connected = true;
      });
      return Appliances.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      setState(() {
        connected = false;
      });
      throw Exception('Failed to load album');
    }
  }

  Future<void> updateStatus(String name, int status) async {
    final response = await http.get(
        Uri.parse('http://$serverIp/api/appliances/$name/$status'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      debugPrint("response: Success");
      setState(() {
        connected = true;
      });
      appliances = fetchListAppliances();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      setState(() {
        connected = false;
      });
      throw Exception('Failed to update name');
    }
  }

  @override
  void initState() {
    super.initState();
    getServerIp();
    appliances = fetchListAppliances();
    timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        appliances = fetchListAppliances(); /**/
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

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  @override
  Widget build(BuildContext context) {

    TextStyle customTextStyle = const TextStyle(
      fontFamily: 'Roboto', // Change to your desired font family
      fontSize: 20.0, // Change to your desired font size
      fontWeight: FontWeight.bold, // You can also specify the font weight
      color: Colors.white, // You can set the text color as well
    );

    return Scaffold(
      body: Container(
        color: const Color(0xFF35BDCB),
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Card(
              color: connected == true ? Colors.amber[800] : Colors.red,
              elevation: 3,
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onLongPress: () {
                  debugPrint('Card Tapped');

                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("Enter Server Ip"),
                        content: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '',
                          ),
                          onChanged: (value) {
                            enteredServerIp = value;
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              enteredServerIp = '';
                              Navigator.pop(context, 'Cancel');
                            },
                            child: const Text(
                              'Cancel',
                            ),
                          ),
                          TextButton(onPressed: () {
                            setServerIp(enteredServerIp);
                            Navigator.pop(context, 'OK');
                          }, child: const Text('OK'))
                        ],
                      ));
                },
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: IconButton(
                        icon: const Icon(Icons.logout),
                        tooltip: 'Logout',
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'STATUS',
                            style: customTextStyle,
                          ),
                          connected == true
                              ? Text(
                            'CONNECTED',
                            style: customTextStyle,
                          )
                              : Text(
                            'DISCONNECT',
                            style: customTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "APPLIANCES",
                    style: customTextStyle,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Card(
                color: const Color(0xFF35BDCB),
                elevation: 3,
                child: SizedBox(
                  width: double.infinity,
                  child: FutureBuilder<Appliances>(
                    future: appliances,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: snapshot.data?.appliances.length,
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
                                      onLongPress: () {},
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
                                                snapshot.data!.appliances[index]
                                                        .name.isNotEmpty
                                                    ? Text(
                                                        "Name: ${snapshot.data!.appliances[index].name}")
                                                    : const SizedBox(),
                                                Text(
                                                    "Status: ${snapshot.data!.appliances[index].status ? "ON" : "OFF"}"),
                                              ],
                                            ),
                                            Switch(
                                              thumbIcon: thumbIcon,
                                              value: snapshot.data!
                                                  .appliances[index].status,
                                              onChanged: (bool value) {
                                                setState(() {
                                                  light1 = value;
                                                  updateStatus(
                                                    snapshot.data!.appliances[index].name,
                                                    value ? 1 : 0
                                                  );
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      }
                      return Center(child: const CircularProgressIndicator());
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
