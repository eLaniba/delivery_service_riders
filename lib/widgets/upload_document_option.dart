import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadDocumentOption extends StatelessWidget{
  final Function(ImageSource, String) onImageSelected;
  final String docType;

  const UploadDocumentOption({Key? key, required this.onImageSelected, required this.docType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16,),
          Row(
            children: [
              //Use Camera
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  // _getImage(ImageSource.camera);
                  onImageSelected(ImageSource.camera, docType);
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      child: Icon(Icons.camera_alt_outlined),
                    ),
                    Text('Camera'),
                  ],
                ),
              ),
              SizedBox(width: 24,),
              //Use Gallery
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  // _getImage(ImageSource.gallery);
                  onImageSelected(ImageSource.gallery, docType);
                },
                child: Column(
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