import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../model/card_details.dart';
import '../services/card_parser.dart';

class CardScannerScreen extends StatefulWidget {
  const CardScannerScreen({super.key});

  @override
  State<CardScannerScreen> createState() =>
      _CardScannerScreenState();
}

class _CardScannerScreenState
    extends State<CardScannerScreen> {

  final ImagePicker _picker =
  ImagePicker();

  File? imageFile;

  bool isLoading = false;

  String error = '';

  CardDetails? cardDetails;

  Future<void> pickImage(
      ImageSource source) async {

    final picked =
    await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      imageFile = File(picked.path);
      isLoading = true;
      error = '';
      cardDetails = null;
    });

    await processImage();
  }

  Future<void> processImage() async {

    if (imageFile == null) return;

    try {

      final inputImage =
      InputImage.fromFile(imageFile!);

      final textRecognizer =
      TextRecognizer();

      final result =
      await textRecognizer
          .processImage(inputImage);

      String rawText = result.text;

      debugPrint(
          '============= CARD OCR RAW TEXT =============');

      debugPrint(rawText);

      final parsed =
      CardParser.parseCard(rawText);

      setState(() {
        cardDetails = parsed;
        isLoading = false;

        if (parsed.cardNumber.isEmpty &&
            parsed.expiryDate.isEmpty &&
            parsed.cardHolder.isEmpty) {

          error =
          'No card details detected';
        }
      });

      textRecognizer.close();

    } catch (e) {

      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  Widget buildResultCard() {

    if (cardDetails == null) {
      return const SizedBox();
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 20),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            const Text(
              'Extracted Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            buildTile(
              'Card Number',
              cardDetails!.cardNumber,
            ),

            buildTile(
              'Expiry Date',
              cardDetails!.expiryDate,
            ),

            if (cardDetails!.cardHolder.isNotEmpty)

              buildTile(
                'Card Holder',
                cardDetails!.cardHolder,
              )

            else

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Container(
                    padding:
                    const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                      Colors.orange.shade50,
                      borderRadius:
                      BorderRadius.circular(12),
                      border: Border.all(
                        color:
                        Colors.orange.shade200,
                      ),
                    ),
                    child: Row(
                      children: [

                        const Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Card holder name not found.\nSome cards print name on backside.',
                            style: TextStyle(
                              color:
                              Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    decoration:
                    InputDecoration(
                      labelText:
                      'Enter Card Holder Name',
                      hintText:
                      'e.g. HARDIK PARMAR',
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      prefixIcon:
                      const Icon(Icons.person),
                    ),
                  ),
                ],
              ),          ],
        ),
      ),
    );
  }

  Widget buildTile(
      String title,
      String value,
      ) {

    return Padding(
      padding:
      const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value.isEmpty
                ? 'Not Found'
                : value,
            style: TextStyle(
              color: value.isEmpty
                  ? Colors.red
                  : Colors.black,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Card Scanner'),
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [

            if (imageFile != null)
              ClipRRect(
                borderRadius:
                BorderRadius.circular(16),
                child: Image.file(
                  imageFile!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        pickImage(
                            ImageSource.camera),
                    icon:
                    const Icon(Icons.camera_alt),
                    label:
                    const Text('Camera'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        pickImage(
                            ImageSource.gallery),
                    icon:
                    const Icon(Icons.photo),
                    label:
                    const Text('Gallery'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (isLoading)
              const CircularProgressIndicator(),

            if (error.isNotEmpty)
              Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),

            buildResultCard(),
          ],
        ),
      ),
    );
  }
}