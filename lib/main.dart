import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GasBotty',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GasBotty')),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 50),
                Container(
                  height: 150, 
                  width: 150,
                  color: Colors.grey,
                  child: Center(child: Text("Logo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                ),
                SizedBox(height: 10),
                Text("GasBotty", style: TextStyle(fontSize: 20)),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    minimumSize: Size(200, 50),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen()));
                  },
                  child: Text('Camera'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    minimumSize: Size(200, 50),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PriceMatchScreen()));
                  },
                  child: Text('Price Match'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10.0, 
            left: 10.0,
            child: Container(
              height: 50.0,
              width: 50.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(12),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingScreen()));
                },
                child: Icon(Icons.settings, size: 24.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notifications'),
            value: false, 
            onChanged: (bool value) {
              // what button does when changed
            },
          ),
          SwitchListTile(
            title: const Text('Appearance'),
            value: false, 
            onChanged: (bool value) {
              // what button does when changed
            },
          ),
        ],
      ),
    );
  }
}

class PriceMatchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Price match')),
      body: Center(child: Text('something')),
    );
  }
}

class ConfirmationScreen extends StatefulWidget {
  final String responseString;

  const ConfirmationScreen({Key? key, required this.responseString}) : super(key: key);

  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  List<Map<String, dynamic>> parsedGasPrices = [];

  @override
  void initState() {
    super.initState();
    parseAndHandleResponse(widget.responseString);
  }

  void parseAndHandleResponse(String response) {
    // Assuming 'response' is the full string you're starting with
    // Implement the parsing logic as described previously

    // Example parsing logic (simplified for demonstration)
    String bodyMarker = "'body': ";
    int start = response.indexOf(bodyMarker) + bodyMarker.length;
    int end = response.lastIndexOf("'}");
    String bodyContent = response.substring(start + 1, end);

    List<String> gasPrices = bodyContent.split(r"\n");

    for (String price in gasPrices) {
      if (price.isNotEmpty) {
        Map<String, dynamic> gasOption = jsonDecode(price);
        parsedGasPrices.add(gasOption);
      }
    }

    setState(() {}); // Update the UI after parsing
  }

  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parsed Gas Prices')),
      body: ListView.builder(
        itemCount: parsedGasPrices.length,
        itemBuilder: (BuildContext context, int index) {
          String key = '${parsedGasPrices[index]["Grade"]} (${parsedGasPrices[index]["Cash/Credit"]})';
          return ListTile(
            title: Text(key),
            subtitle: Text("\$${parsedGasPrices[index]["Price"].toString()}"),
          );
        },
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
      );

      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    }
  }

Future<void> _takePicture() async {
  if (!_controller!.value.isInitialized) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: select a camera first.')),
  );
  return;
  }
  if (_controller!.value.isTakingPicture) {
  return;
  }
  try {
    final XFile? file = await _controller!.takePicture();
    if (file != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child("images/${DateTime.now().millisecondsSinceEpoch}.png");
      await imageRef.putFile(File(file.path));
      final downloadUrl = await imageRef.getDownloadURL();
      String responseString = r'''{'statusCode': 200, 'headers': {'Content-Type': '/'}, 'body': '{"Price":3.039,"Grade":"Regular","Cash\/Credit":"Cash"}\n{"Price":3.139,"Grade":"Mid-Grade","Cash\/Credit":"Cash"}\n{"Price":3.139,"Grade":"Regular","Cash\/Credit":"Credit"}\n{"Price":3.239,"Grade":"Mid-Grade","Cash\/Credit":"Credit"}\n{"Price":3.239,"Grade":"Premium","Cash\/Credit":"Cash"}\n{"Price":3.339,"Grade":"Premium","Cash\/Credit":"Credit"}\n{"Price":3.399,"Grade":"Diesel","Cash\/Credit":"Cash"}\n{"Price":3.399,"Grade":"Diesel","Cash\/Credit":"Credit"}\n'}''';
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(responseString: responseString),
        ),
      );

      /*
      var data = jsonEncode({'image': imgBase64Str});
      var url = Uri.parse('https://dwljoaahjk.execute-api.us-east-2.amazonaws.com/2/GasBottyLambda'); //API endpoint
      var headers = {'Content-Type': 'application/json'};
      
      //var response = await http.post(url, body: data, headers: headers);
      
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body); //the reponse back
      } else {
        print('Failed to load post');
      }*/


      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Picture uploaded and data parsed')),
        );
      });
    }
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to take picture and parse data')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CameraPreview(_controller!),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera),
              label: const Text('Take Picture'),
              onPressed: _takePicture,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}