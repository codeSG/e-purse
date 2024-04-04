// other_class.dart
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  late final BuildContext context;
  late final String imageUrl;
  late final IconData iconData;
  late final VoidCallback onPressedFunction;

  MyWidget({
    required this.context,
    required this.imageUrl,
    required this.iconData,
    required this.onPressedFunction,
  });
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

  Widget maintile(BuildContext context, Icon icon, String image, void Function()? onpressed ) {
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
              child: Image.asset(image),
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
                          icon: Icons.camera_alt_outlined, onpressed: onPressedFunction,)
                    ]),
              )
            ]
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Your widget's content
      child: maintile(context, Icon(iconData)!,imageUrl, onPressedFunction)
    );
  }
}
