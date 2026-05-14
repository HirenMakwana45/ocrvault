import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocrvault/screens/result_card.dart';

import '../model/bank_details.dart';
import '../services/ocr_service.dart';
import '../services/passbook_parser.dart';
import '../widgets/error_view.dart';
import '../widgets/image_preview.dart';
import '../widgets/result_card.dart';

class PassbookScannerScreen
    extends StatefulWidget {
  const PassbookScannerScreen({super.key});

  @override
  State<PassbookScannerScreen> createState() =>
      _PassbookScannerScreenState();
}

class _PassbookScannerScreenState
    extends State<PassbookScannerScreen> {
  File? imageFile;

  BankDetails? bankDetails;

  bool isLoading = false;

  String error = '';

  String lastScan = '';

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      imageFile = File(picked.path);
      error = '';
      isLoading = true;
    });

    try {
      /// OCR RESULT
      final RecognizedText ocrResult =
      await OCRService.scanText(
        picked.path,
      );

      /// RAW TEXT
      final rawText = ocrResult.text;

      print(
          "============= PASSBOOK OCR RAW TEXT =============");
      print(rawText);

      /// DEBUG BLOCKS
      for (final block in ocrResult.blocks) {
        print("BLOCK => ${block.text}");

        for (final line in block.lines) {
          print("LINE => ${line.text}");
        }
      }

      /// DUPLICATE CHECK
      if (rawText == lastScan) {
        setState(() {
          isLoading = false;
          error = 'Duplicate scan detected';
        });

        return;
      }

      lastScan = rawText;

      /// PARSE PASSBOOK
      final result =
      PassbookParser.parsePassbook(
        rawText,
      );

      setState(() {
        bankDetails = result;

        print(
          "BANK DETAILS => "
              "Name: ${bankDetails?.accountHolder}, "
              "Acc: ${bankDetails?.accountNumber}, "
              "IFSC: ${bankDetails?.ifscCode}",
        );

        isLoading = false;

        if (result.isEmpty) {
          error = 'No bank details found';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Failed to scan passbook';
      });

      print("PASSBOOK SCAN ERROR => $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Passbook Scanner"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            /// IMAGE PREVIEW
            if (imageFile != null)
              ImagePreview(image: imageFile!),

            const SizedBox(height: 20),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        pickImage(ImageSource.camera),
                    icon:
                    const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text("Gallery"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (isLoading)
              const CircularProgressIndicator(),

            if (error.isNotEmpty)
              ErrorView(message: error),

            /// RESULT
            if (bankDetails != null &&
                !bankDetails!.isEmpty)
              ResultCard(
                title: "Bank Details",
                children: [
                  buildTile(
                    "Account Holder",
                    bankDetails!.accountHolder,
                  ),
                  buildTile(
                    "Account Number",
                    bankDetails!.accountNumber,
                  ),
                  buildTile(
                    "IFSC Code",
                    bankDetails!.ifscCode,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTile(String label, String value) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}