import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await Hive.openBox('login');
  var box = Hive.box('login');
  var name = box.get('name');
  DateTime datetime = (box.get('time') == null)
      ? DateTime.parse("2012-02-27 13:27:00")
      : box.get('time');
  var limit = datetime.add(const Duration(seconds: 90));
  print(name);
  print(limit);
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ((name == null) || (limit.isBefore(DateTime.now())))
          ? Login()
          : TapboxA()));
}

class Login extends StatelessWidget {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                icon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                hintText: 'Your name',
              ),
            ),
            TextField(
              obscureText: true,
              controller: _passwordController,
              decoration: const InputDecoration(
                icon: Icon(Icons.password, color: Colors.black),
                hintText: 'Password',
              ),
            ),
            FloatingActionButton.extended(
              label: const Text('Login'),
              heroTag: 'contact1',
              onPressed: () async {
                login(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    final url =
        Uri.parse('https://sampleapiproject.azurewebsites.net/api/auth');
    final response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "username": _nameController.text,
          "password": _passwordController.text,
        }));
    if (response.statusCode == 200) {
      var box = Hive.box('login');
      box.put('name', _nameController.text);
      box.put('password', _passwordController.text);
      box.put('time', DateTime.now());

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (BuildContext ctx) => Home()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login unsuccessful")));
    }
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: FloatingActionButton.extended(
          onPressed: () async {
            var box = Hive.box('login');
            box.delete('name');
            box.delete('password');
            box.delete('time');
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext ctx) => Login()));
          },
          heroTag: 'contact2',
          label: const Text('Logout'),
        ),
      ),
    );
  }
}

class TapboxA extends StatefulWidget {
  @override
  _TapboxAState createState() => _TapboxAState();
}

class _TapboxAState extends State<TapboxA> {
  Future<String> login() async {
    var box = Hive.box('login');
    var name = box.get('name');
    var password = box.get('password');
    final url =
        Uri.parse('https://sampleapiproject.azurewebsites.net/api/auth');
    final response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "username": name,
          "password": password,
        }));
    final jsonResponse = jsonDecode(response.body);
    final jsonToken = jsonResponse["token"];
    final jsonauthToken = jsonToken["authToken"];
    print(jsonauthToken);
    return response.body;
  }

  @override
  void initState() {
    login();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(child: Home()),
    );
  }
}
