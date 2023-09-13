import 'package:flutter/material.dart';

class NetworkScanningScreen extends StatelessWidget {
  NetworkScanningScreen({super.key});

  final List<String> items = <String>["network 1", "network 2"];


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
