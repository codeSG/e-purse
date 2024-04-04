// HomePage.dart
import 'package:documentkeeper/image.dart';
import 'package:documentkeeper/location.dart';
import 'package:documentkeeper/mapwithmarker.dart';
import 'package:flutter/material.dart';

import 'cred.dart';
void main() {
  runApp(MaterialApp(
    title: 'Docuement',
    home: HomePage(),
  ),);
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width*0.8,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the second page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DisplayStoredDataScreen()),
                    );
                  },
                  child: Text('Login credentials',
                    style: TextStyle(color: Colors.white, fontSize: 25),),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width*0.8,
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the second page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: "Image")),
                    );
                  },
    style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
    ),
                  child: Text('Save Documents',style: TextStyle(color: Colors.white, fontSize: 25),),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width*0.8,
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the second page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapWithMarker()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child: Text('Save Location',style: TextStyle(color: Colors.white, fontSize: 25),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
