import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  String password = '';
  String email = '';
  String enteredServerIp = "";
  late SharedPreferences prefs;
  late String serverIp;

  Future<void> getServerIp() async {
    prefs = await SharedPreferences.getInstance();
    serverIp = prefs.getString('serverIp') ?? '192.168.100.57:8080';
  }

  Future<void> setServerIp(String ip) async {
    await prefs.setString('serverIp', ip);
    getServerIp();
  }

  Future<void> login(String email, String password) async {
    final response = await http
        .get(Uri.parse('http://$serverIp/api/login/$email/$password'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      debugPrint("response: Success");
      if (response.body == 'True') {
        setState(() {
          Navigator.pushReplacementNamed(context, '/second');
        });
      } else {
        setState(() {
          // If Success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed!'),
            ),
          );
        });
      }

      // return Appliances.fromJson(jsonDecode(response.body));
      debugPrint('response from login: ' + response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      setState(() {
        // connected = false;
        // If Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed!'),
          ),
        );
      });
      throw Exception('Failed to load album');
    }
  }

  @override
  void initState() {
    super.initState();
    getServerIp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF35BDCB),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              child: const SelectionContainer.disabled(
                  child: Text(
                'Login',
                style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )),
              onLongPress: () {
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
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 300,
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    filled: true),
                onChanged: (text) {
                  email = text;
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 300,
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    filled: true),
                onChanged: (text) {
                  password = text;
                },
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                  onPressed: () {
                    if (email.isNotEmpty && password.isNotEmpty) {
                      login(email, password);
                    }
                    // If Success
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text('$email, $password'),
                    //   ),
                    // );
                  },
                  child: const Text('Sign In')),
            )
          ],
        ),
      ),
    );
  }
}
