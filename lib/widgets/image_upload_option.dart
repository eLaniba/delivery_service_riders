import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadOption extends StatelessWidget{
  final Function(ImageSource) onImageSelected;

  const ImageUploadOption({Key? key, required this.onImageSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16,),
          Row(
            children: [
              //Use Camera
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  // _getImage(ImageSource.camera);
                  onImageSelected(ImageSource.camera);
                },
                child: const Column(
                  children: [
                    CircleAvatar(
                      child: Icon(Icons.camera_alt_outlined),
                    ),
                    Text('Camera'),
                  ],
                ),
              ),
              const SizedBox(width: 24,),
              //Use Gallery
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  // _getImage(ImageSource.gallery);
                  onImageSelected(ImageSource.gallery);
                },
                child: const Column(
                  children: [
                    CircleAvatar(
                      child: Icon(Icons.image_outlined),
                    ),
                    Text('Gallery'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}