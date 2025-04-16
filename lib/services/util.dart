import 'dart:io';

import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/models/sales.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

String orderDateRead(DateTime orderDateTime) {
  String formattedOrderTime = DateFormat('MMMM d, y h:mm a').format(orderDateTime);
  return formattedOrderTime;
}

String capitalizeEachWord(String input) {
  if (input.isEmpty) return input;
  return input.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

String formatPhoneNumber(String input) {
  // Trim any surrounding whitespace.
  String trimmed = input.trim();

  // Remove a leading "+63" if it exists.
  if (trimmed.startsWith('+63')) {
    trimmed = trimmed.substring(3);
  }
  // Otherwise, if it starts with a "0", remove that.
  else if (trimmed.startsWith('0')) {
    trimmed = trimmed.substring(1);
  }

  // Return the number with the "+63" prefix appended.
  return '+63$trimmed';
}

String reformatPhoneNumber(String input) {
  // Trim any surrounding whitespace.
  String trimmed = input.trim();

  // Remove a leading "+63" if it exists.
  if (trimmed.startsWith('+63')) {
    trimmed = trimmed.substring(3);
  }


  // Return the number with the "+63" prefix appended.
  return '0$trimmed';
}

//Upload an image to Firestore Cloud Storage and return the ImageURL
Future<String> uploadFileAndGetDownloadURL({
  required XFile file,
  required String storagePath,
}) async {
  final ref = firebaseStorage.ref(storagePath);
  final uploadTask = ref.putFile(File(file.path));
  final snapshot = await uploadTask;
  return await snapshot.ref.getDownloadURL();
}

/// Looks for a specific phrase in the recognized text lines.
/// Returns true if any line contains [phrase], otherwise false.
Future<bool> validateImage(XFile imageFile, String phrase) async {
  final textRecognizer = TextRecognizer();

  try {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final recognizedText = await textRecognizer.processImage(inputImage);

    // Go through each TextBlock -> each TextLine, checking if line text contains [phrase].
    for (final block in recognizedText.blocks) {
      print(block.text);
      for (final line in block.lines) {
        // If you need an exact match, do line.text.trim() == phrase
        if (line.text.contains(phrase)) {
          return true;
        }
      }
    }
    return false;
  } catch (e) {
    print('Error searching for $phrase in image: $e');
    return false;
  } finally {
    textRecognizer.close();
  }
}

double calculateServiceFeeTotal(List<Sales> sales) {
  return sales.fold(0.0, (sum, sale) => sum + sale.serviceFeeTotal);
}

double calculateTotalEarnings(List<Sales> sales) {
  return sales.fold(0.0, (sum, sale) => sum + sale.earnings);
}

Future<void> updateRiderStatus(String status) async {
  final riderID = sharedPreferences!.getString('uid');
  if (riderID == null) return;

  await firebaseFirestore.collection('riders').doc(riderID).update({
    'riderStatus': status,
  });
}