import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:maps_launcher/maps_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final imagepath_ = '/storage/emulated/0/Android/data/com.example.documentkeeper/files/image';

  Future<Directory?> createFolderInExternalStorage() async {
    // Get the external storage directory
    Directory? externalStorageDir = await getExternalStorageDirectory();
    try {


      // Define the name of the folder you want to create
      String folderName = 'image';

      // Create a new directory within the external storage directory
      Directory newFolder = Directory('${externalStorageDir?.path}/$folderName');

      // Check if the directory already exists
      if (await newFolder.exists()) {
        print('Folder already exists');
      } else {
        // Create the directory if it doesn't exist
        await newFolder.create(recursive: true);
        print('Folder created');
      }
      return newFolder;
    } catch (e) {
      print('Error creating folder: $e');
    }
    return externalStorageDir;
  }

  File? imageFile;
  String imageName = '';

  Future _pickImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
       // _cropImage();
      });
    }
  }

/*  Future _cropImage() async {
    if (imageFile != null) {
      File? cropped = await ImageCropper().cropImage(
          sourcePath: imageFile!.path,
          aspectRatioPresets:
          [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            title: 'Cropper',
          )
      );

      if (cropped != null) {
        setState(() async {
          imageFile = File(cropped.path);
          await saveimage(imageFile);
        });
      }
      else
      {
        setState(() async {
          await saveimage(imageFile);

        });
      }

    }
  }*/

  void _showDeleteFileDialog(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation Dialog'),
          content: Text('Do you want to delete this file?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                // Perform the confirmed action here
                // ...
                deleteFile(image);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }



  void _showImageAlertDialog(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: Text(path.basenameWithoutExtension(image.path)),
          content: Image.file(image,
              width: MediaQuery.of(context).size.width*0.8,
              height: MediaQuery.of(context).size.height*0.8), // Replace with your image path
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Share'),
              onPressed: () {
                // Close the dialog
                //Share.shareFiles([image.path] as List<String>);
                share();
              },
            ),

          ],
        );
      },
    );
  }

  Future<void> _showNameInputDialog(BuildContext context) async {
    return showDialog<void>(
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Your Name'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                imageName = value;
              });
            },
            decoration: InputDecoration(labelText: 'Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // You can use the 'userName' variable here to access the entered name.
                print('Entered File Name: $imageName');
              },
            ),
          ],
        );
      }, context: context,
    );
  }

  List<File> imageFiles = [];

  Future<List<File>> getImageFilesInDirectory(final directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        final files = directory.listSync();
        final imageFiles = files.where((file) {
          print(file);
          return file is File && (file.path.endsWith('.jpg') || file.path.endsWith('.png'));
        }).map((file) => File(file.path)).toList();
        return imageFiles;
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting image files: $e');
      return [];
    }
  }


  Future<void> loadImages() async {
    final directoryPath = imagepath_; // Replace with your directory path
    final images = await getImageFilesInDirectory(directoryPath);
    setState(() {

      imageFiles = images;
      print(imageFiles.length);
    });
  }

  Future<void> saveimage(pickedFile) async {
    final externalStorageDir = await createFolderInExternalStorage();
    await _showNameInputDialog(context);
    if (externalStorageDir != null) {
      // Create a new file in the external storage directory
      //final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final imagePath = '${externalStorageDir.path}/$imageName'+ '.jpg';

      // Copy the picked image to the external storage directory
      await pickedFile.copy(imagePath);

      print('Image saved to $imagePath');
    } else {
      print('External storage directory is not available.');
    }
    setState(() {
      loadImages();
      print("Updated");
    });

  }
  void _clearImage() {
    setState(() {
      imageFile = null;
    });
  }

  void deleteFile(file) async {
    //final file = File('path_to_your_file.txt'); // Replace with the actual path to your file.

    try {
      await file.delete();
      print('File deleted successfully.');
      loadImages();
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  Widget _buildIconButton(
      {required IconData icon, required void Function()? onpressed}) {
    return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(10)),
        child: IconButton(
          onPressed: onpressed,
          icon: Icon(icon),
          color: Colors.white,
        ));
  }

  Widget maintile() {
    return Center(child: Container( // Width of the box
        width: MediaQuery
            .of(context as BuildContext)
            .size
            .width,
        height: 80,
        // Height of the box
        margin: EdgeInsets.all(10),
        color: Colors.blue.shade200,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/images/id.jpg"),
            ),
              SizedBox(width: 10,),
              Container(
                //color: Colors.white,
                width: MediaQuery
                    .of(context as BuildContext)
                    .size
                    .width * 0.30,
                child: Text("Add Image", style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),),
              ),
              Container(
                width: MediaQuery
                    .of(context as BuildContext)
                    .size
                    .width * 0.3,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIconButton(
                          icon: Icons.camera_alt_outlined, onpressed: () {

                        _pickImage();
                      }),
                    ]),
              )
            ]
        )));
  }

  Widget tile(String title, File imageFile) {
    return Center(child: InkWell(
      child: Container( // Width of the box
          width: MediaQuery
              .of(context as BuildContext)
              .size
              .width,
          height: 80,
          // Height of the box
          margin: EdgeInsets.all(10),
          color: Colors.blue.shade100,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(imageFile, width: 50, height: 50,),
              ),
                SizedBox(width: 10,),
                Container(
                  //color: Colors.white,
                  width: MediaQuery
                      .of(context as BuildContext)
                      .size
                      .width * 0.35,
                  child: Text(title, style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),),
                ),
                Container(
                  width: MediaQuery
                      .of(context as BuildContext)
                      .size
                      .width * 0.4,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconButton(
                            icon: Icons.image_outlined, onpressed: () {

                          _showImageAlertDialog(context,imageFile);  }),
                        _buildIconButton(
                            icon: Icons.share_outlined, onpressed: () {
                          //Share.shareFiles([imageFile.path] as List<String>);
                          //Share.shareUri(Uri());
                          share();
                        }),
                        _buildIconButton(
                            icon: Icons.delete_forever_outlined, onpressed: () {
                          _showDeleteFileDialog(context, imageFile);
                        }),
                      ]),
                )
              ]
          )),
    ));
  }

  void launchMap(double latitude, double longitude) async {
    //String mapUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    /*String mapUrl = Uri.encodeFull('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    if (await canLaunchUrlString(mapUrl)) {
      await launchUrlString(mapUrl);
    } else {
      print('Could not launch $mapUrl');
    }*/
    MapsLauncher.launchCoordinates(24.5536,73.7284);
  }

  void share(){
  double latitude = 37.7749;
  double longitude = -122.4194;

  launchMap(latitude, longitude);
}

  Widget displayImages(List<File> imageFiles) {
    return Expanded(

        child: ListView.builder(
          itemCount: imageFiles.length,
          itemBuilder: (BuildContext context, int index) {
            final imageFile = imageFiles[index];
            return tile(path.basenameWithoutExtension(imageFile.path), imageFile);
          },
        )
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    loadImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return
    Scaffold(
      appBar: AppBar(
        title: Text('Display Documents:'),
    ),

      body: Container(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            maintile(),
            imageFiles.isEmpty
                ? Center(
              child: Text('No images found.'),
            )
                : displayImages(imageFiles),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

