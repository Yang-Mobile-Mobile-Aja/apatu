import 'dart:io';

class ScannerState {
  final File? imageFile;
  final String extractedText;

  ScannerState({this.imageFile, this.extractedText = ''});
}