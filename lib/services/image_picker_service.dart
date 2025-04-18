import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  Future<XFile?> pickCropImage({
    required CropAspectRatio cropAspectRatio,
    required ImageSource imageSrouce,
  }) async {
    //Pick image
    XFile? pickImage = await ImagePicker().pickImage(source: imageSrouce);
    if (pickImage == null) return null;

    //Crop picked image
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickImage.path,
      aspectRatio: cropAspectRatio,
      compressQuality: 80,
      compressFormat: ImageCompressFormat.jpg,
    );
    if (croppedFile == null) return null;

    return XFile(croppedFile.path);
  }
}