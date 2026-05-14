import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static Future<RecognizedText> scanText(
      String imagePath,
      ) async {
    final inputImage =
    InputImage.fromFilePath(imagePath);

    final recognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );

    final result =
    await recognizer.processImage(inputImage);

    await recognizer.close();

    return result;
  }
}