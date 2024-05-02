import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard.dart';

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Page',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final String server = "http://localhost/";

  // Define TextEditingController as final to ensure immutability
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF039C60),
      body: Stack(
        children: [
          Positioned(
            top: 60.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 0.0),
                  child: Image.network(
                    'https://i.postimg.cc/yxkLtVq3/removal-ai-a828ce7f-c776-4499-8024-01fce6fcff2a-grey-and-white-simple-product-inventory-planner.png',
                    width: 100,
                    height: 220,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 0.0, top: 50.0),
                  child: Text(
                    'BOOKIFY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 60.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 220.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Your number one partner in bookkeeping',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 100.0,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF555555),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey,
                        ),
                      ),
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                          hintText: "Enter Username",
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey,
                        ),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                          hintText: "Enter Password",
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        _login(context);
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF039C60),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    final url = Uri.parse(server + "book/login/loginAuthentication.php");
    final response = await http.post(
      url,
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 422) {
        // Show error message for invalid username or password
        _showErrorDialog(context, responseData['message']);
      } else if (responseData['status'] == 404) {
        // Show error message for incorrect username or password
        _showErrorDialog(context, "Incorrect username or password.");
      } else {
        // Authentication successful, navigate to dashboard
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(
              title: 'Bookify',
              titleTextStyle: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } else {
      // Show error message
      _showErrorDialog(context, "Failed to connect to the server. Please try again later.");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
