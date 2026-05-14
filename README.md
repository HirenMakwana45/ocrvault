# OCR Vault – Card & Passbook Scanner

A Flutter application that scans credit/debit cards and bank passbooks using OCR and extracts structured information using custom parsing logic.

---

# Features

## 1. Card Scanner
- Scan using camera
- Upload from gallery
- Extract:
    - Card Number
    - Expiry Date
    - Card Holder Name (if available)
- Luhn Algorithm validation
- Mask card number in UI
- Handles OCR mistakes and noisy scans

---

## 2. Passbook / Bank Document Scanner
- Scan using camera
- Upload image from gallery
- Extract:
    - Account Holder Name
    - Account Number
    - IFSC Code
- Handles OCR noise and multiple numbers
- Structured UI display

---

# Tech Stack

- Flutter
- Dart
- Google ML Kit OCR

---

# Libraries Used

| Library | Purpose |
|---|---|
| google_mlkit_text_recognition | OCR text extraction |
| image_picker | Camera & gallery image selection |
| flutter | UI framework |

---

# Project Structure

```txt
lib/
│
├── model/
│   ├── bank_details.dart
│   └── card_details.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── card_scanner_screen.dart
│   └── passbook_scanner_screen.dart
│
├── services/
│   ├── card_parser.dart
│   ├── passbook_parser.dart
│   └── luhn_validator.dart
│
└── main.dart
```

---

# Core Algorithms Implemented

## 1. Card Parser
Function:
```dart
CardDetails parseCard(String rawText)
```

Implemented manually:
- Card number detection
- OCR cleanup
- Expiry extraction
- Name extraction
- Multiple format handling

Supported:
- `1234 5678 9012 3456`
- `1234-5678-9012-3456`
- multiline OCR numbers

---

## 2. Passbook Parser
Function:
```dart
BankDetails parsePassbook(String rawText)
```

Implemented manually:
- Account number detection
- IFSC extraction
- Noisy name cleanup
- CIF filtering
- OCR correction handling

---

## 3. Luhn Algorithm
Function:
```dart
bool isValidCard(String cardNumber)
```

Implemented manually without external package.

Used to validate:
- Visa
- Mastercard
- RuPay
- Debit/Credit card numbers

---

# OCR Edge Cases Handled

- O → 0
- I → 1
- S → 5
- B → 8
- multiline card numbers
- blurry scans
- missing holder names
- noisy OCR output
- multiple numbers in passbooks
- partial scans

---

# UI Features

- Clean Flutter UI
- Image preview
- Loading states
- Error states
- Structured extracted data
- Manual fallback for missing card holder name

---

# Steps to Run the Project

## 1. Clone Repository

```bash
git clone <repo_url>
```

---

## 2. Open Project

```bash
cd ocrvault
```

---

## 3. Install Dependencies

```bash
flutter pub get
```

---

## 4. Run Application

```bash
flutter run
```

---

# Android Permissions

The following permissions are required:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

```

---

# Testing

Implemented tests for:
- Card Parser
- Passbook Parser
- Luhn Validation

Run tests:

```bash
flutter test
```

---

# Assumptions Made

- OCR may not always detect embossed text perfectly
- Some cards do not contain holder name on front side
- IFSC codes may contain OCR corruption
- Passbooks may contain multiple unrelated numbers
- OCR quality depends on image clarity and lighting

---

# What Was Skipped and Why

## 1. Real-time Camera Frame Scanning
Skipped to keep implementation simple and focused on parsing logic.

## 2. Backend Services
Not implemented because assignment explicitly restricted backend usage.

## 3. Advanced AI/ML Post-processing
Skipped because requirement focused on manual parsing logic instead of external AI services.

## 4. Multi-language OCR
Current implementation focuses on English OCR only.

## 5. Perfect OCR Accuracy
OCR inaccuracies are expected in blurry or reflective card surfaces. Manual fallback input is provided where necessary.

---

# Future Improvements

- Real-time edge detection
- Better image preprocessing
- Multi-frame OCR scanning
- Auto-crop card detection
- Better confidence scoring
- Multi-language support

---

# Author

Hiren Makwana
Flutter Developer