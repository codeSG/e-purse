import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWithMarker extends StatefulWidget {
  @override
  _MapWithMarkerState createState() => _MapWithMarkerState();
}

class _MapWithMarkerState extends State<MapWithMarker> {
  late GoogleMapController _controller;
  Set<Marker> _markers = Set();

  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: GoogleMap(
          onMapCreated: (controller) {
            _controller = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(37.7749, -122.4194), // San Francisco coordinates
            zoom: 12.0,
          ),
          markers: _markers,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addMarker();
          _captureMap();
        },
        child: Icon(Icons.camera),
      ),
    );
  }

  void _addMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('1'),
          position: LatLng(37.7749, -122.4194), // Marker position
          infoWindow: InfoWindow(title: 'Marker 1'),
        ),
      );
    });
  }

  Future<void> _captureMap() async {
    try {
      RenderObject? boundary = _repaintBoundaryKey.currentContext?.findRenderObject();

      // Create a picture key
      ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas canvas = Canvas(recorder);
      boundary?.paint(canvas as PaintingContext, Offset.zero);

      // Convert the picture to an image
      ui.Image image = await recorder.endRecording().toImage(
        300,300
      );

      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? uint8List = byteData?.buffer.asUint8List();

      // Save the image buffer or use it as needed
      // For example, you can use the image in an Image.memory widget or save it to a file.
    } catch (e) {
      print('Error capturing map: $e');
    }
  }
}


