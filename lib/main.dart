import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
//import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

//import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as image;
import 'dart:typed_data';

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
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 20),
                    minimumSize: Size(200, 50),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen()));
                  },
                  child: Text('Camera'),
                ),
                // SizedBox(height: 20),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                //     minimumSize: Size(200, 50),
                //   ),
                //   onPressed: () {
                //     Navigator.push(context, MaterialPageRoute(builder: (context) => PriceMatchScreen()));
                //   },
                //   child: Text('Price Match'),
                // ),
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

// class PriceMatchScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Price match')),
//       body: Center(child: Text('something')),
//     );
//   }
// }

class ConfirmationScreen extends StatefulWidget {
  final String responseString;

  ConfirmationScreen({Key? key, required this.responseString}) : super(key: key);
  
  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>{
  late List<Map<String, dynamic>> entries = [];
  late List<TextEditingController> priceEdit;
  late List<TextEditingController> gradeEdit;
  late List<TextEditingController> cashCreditEdit;

  @override
  Widget build(BuildContext context) {
    //print(responseString);
    var decodedResponse = jsonDecode(widget.responseString);
    var body = decodedResponse['body'];
    //print(body);
    try{
      body = body.replaceAll('"', "").trim();
    } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Server Failed, Value = Null')),
    );
  }
    
    var listbody = body.split('\n');
    listbody.removeLast();
    //print(listbody);
    List<Map<String, dynamic>> entries = [];
    for (var line in listbody){
      line = line.substring(0, line.length-1);
      print(line);
      Map<String, dynamic> linedata = {};
      var dataPoints = line.split(',');
      //print(dataPoints);
      linedata ['Price'] = dataPoints[0].split(':')[1].trim();
      print(linedata);
      linedata ['Grade'] = dataPoints[1].split(':')[1].trim();
      print(linedata);
      linedata ['Cash/Credit'] = dataPoints[2].split(':')[1].trim();
      print(linedata);
      entries.add(linedata);
    }
    print(entries);
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          var entry = entries[index];
          return Padding(padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                //controller: priceEdit[index],
                decoration: InputDecoration(labelText: 'Price'),
                onChanged: (text) => entries[index]['Price'] = text,
                initialValue: entries[index]['Price'],
              ),
              TextFormField(
                //controller: gradeEdit[index],
                decoration: InputDecoration(labelText: 'Grade'),
                onChanged: (text) => entries[index]['Grade'] = text,
                initialValue: entries[index]['Grade'],
                ),
              TextFormField(
                //controller: cashCreditEdit[index],
                decoration: InputDecoration(labelText: 'Cash/Credit'),
                onChanged: (text) => entries[index]['Cash/Credit'] = text, 
                initialValue: entries[index]['Cash/Credit'],
              ),
            ],
          ),
        );
        },
      ),
       bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () async {
              // This will be triggered when the button is pressed
              // Create a reference to the Firestore collection
              CollectionReference gasData = FirebaseFirestore.instance.collection('Gas Data');
              try {
                // Perform the upload to Firestore
                for (var entry in entries) {
                  await gasData.add({
                    'Price': entry['Price'], 
                    'Grade': entry['Grade'],
                    'Cash/Credit': entry['Cash/Credit']
                  });
                }
                // Show a success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Data submitted successfully')),
                );
              } catch (e) {
                // If the upload fails, show an error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to submit data')),
                );
              }
            },
            child: Text('Submit Data'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50) // make the button full width
            ),
          ),
        ),
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
    showDialog(
      context: context,
      barrierDismissible: false, // User must wait
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );
    final XFile? file = await _controller!.takePicture();
    if (file != null) {
      //SAVE ORIGINAL IMAGE TO FIREBASE
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child("images/original/${DateTime.now().millisecondsSinceEpoch}.png");

      int cropSize = 640;
      Uint8List bytes = await File(file.path).readAsBytes();
      image.Image originalImage = image.decodeImage(bytes) as image.Image;

      //CROP IMAGE TO MATCH BORDER
      double scaleFactorX = originalImage.width / MediaQuery.of(context).size.width;
      double scaleFactorY = originalImage.height / MediaQuery.of(context).size.height;
      int cropWidth = (cropSize * scaleFactorX).toInt();
      int cropHeight = (cropSize * scaleFactorY).toInt();
      int offsetX = (originalImage.width - cropWidth) ~/ 2;
      int offsetY = (originalImage.height - cropHeight) ~/ 2;
      image.Image croppedImage = image.copyCrop(originalImage, x: offsetX, y: offsetY, width: cropWidth, height: cropHeight);
      Uint8List pngBytes = image.encodePng(croppedImage);

      //SAVE CROP IMAGE TO FIREBASE
      final st = FirebaseStorage.instance.ref();
      final i = st.child("images/cropped/cropped${DateTime.now().millisecondsSinceEpoch}.png");
      await i.putData(pngBytes);  

      image.Image resizedImage = image.copyResize(croppedImage, width: 640, height: 640);
      Uint8List resizedBytes = image.encodeJpg(resizedImage);

      //SAVE RESIZE IMAGE TO FIREBASE
      final stor = FirebaseStorage.instance.ref();
      final ima = stor.child("images/resized/resized_${DateTime.now().millisecondsSinceEpoch}.jpg");
      await ima.putData(resizedBytes);

      String base64Image = base64Encode(resizedBytes);
      await imageRef.putFile(File(file.path));
      var apiUri = Uri.parse('http://3.15.77.148:81/2015-03-31/functions/function/invocations'); //API
      String jsonData = jsonEncode({'image': base64Image});

      // Set headers for the POST request
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Accept': 'text/plain'
      };
      
      http.Response response =
      await http.post(apiUri, headers: headers, body: jsonData);
      var responseString = response.body.toString();
      print(responseString);
      Navigator.of(context).pop(); // Dismiss the loading indicator

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(responseString: responseString),
          ),
        );
      } else {
        print('Failed to upload image to the API');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image to the API')),
        );
      }

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Picture uploaded and data parsed')),
        );
      });
    }
  } catch (e) {
    Navigator.of(context).pop();
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
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                CameraPreview(_controller!), // Camera Preview
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red, // Color of the border
                      width: 2, // Width of the border
                    ),
                  ),
                  width: 600, // Width of the square
                  height: 600, // Height of the square
                ),
              ],
            ),
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