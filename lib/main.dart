import 'package:flutter/material.dart';

void main() {
  runApp(Homepage());
}

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MH',
      //
      // Gotta love the dark theme
      //
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      //
      // Home is where the coding guidelines are
      //
      home: CodeGuidelines(),
      // home: MyHomePage(title: 'Mahi Home Page :)'),
    );
  }
}

class CodeGuidelines extends StatelessWidget {
  CodeGuidelines({Key key, String title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('{MH}'),
      ),
      body: Column(
        children: [
          //
          // Page title
          //
          Container(
            padding: EdgeInsets.symmetric(vertical: 60),
            color: Colors.orange[900],
            child: Center(
              child: Text(
                'Coding guidelines',
                style: TextStyle(
                  fontSize: 50,
                ),
              ),
            ),
          ),
          //
          // Guidelines content
          //
          Column(),
        ],
      ),
    );
  }
}
