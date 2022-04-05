import 'package:flutter/material.dart';

class ViewImage extends StatefulWidget {
  String imageUrl;
  ViewImage(this.imageUrl, {Key? key}) : super(key: key);

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View image',
        ),
      ),
      body: Center(
        child: Image.network(
          widget.imageUrl,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
