import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'appliancesModel.dart';

class ControlSystemScreen extends StatefulWidget {
  const ControlSystemScreen({super.key});

  @override
  State<ControlSystemScreen> createState() => _ControlSystemScreenState();
}

class _ControlSystemScreenState extends State<ControlSystemScreen> {
  late Future<Appliances> appliances;
  bool light0 = true;
  bool light1 = true;
  bool connected = false;
  late Timer timer;

  Future<Appliances> fetchListAppliances() async {
    final response = await http
        .get(Uri.parse('http://192.168.100.57:8080/api/appliances/list'));

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
        Uri.parse('http://192.168.100.57:8080/api/appliances/$name/$status'));

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
    return Scaffold(
      body: Container(
        color: Colors.green,
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
                    // connected == true ? const Text('CONNECTED') : const Text('DISCONNECT'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Card(
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
            )
          ],
        ),
      ),
    );
  }
}
