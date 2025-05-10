import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanner/presentation/cubit/scanner_state.dart';
import 'package:scanner/presentation/page/profile_screen.dart';
import 'package:scanner/presentation/page/saved_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScannerCubit extends Cubit<ScannerState> {
  ScannerCubit() : super(ScannerState());

  final ImagePicker _imagePicker = ImagePicker();

  // Pick an image from the camera
  Future<void> pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      emit(ScannerState(imageFile: File(pickedFile.path)));
      processImage(File(pickedFile.path));
    }
  }

  // Process image to extract text
  Future<void> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    emit(
      ScannerState(imageFile: imageFile, extractedText: recognizedText.text),
    );
  }

  Future<void> saveToSupabase(BuildContext context) async {
    final state = this.state;
    if (state.imageFile == null || state.extractedText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No image or text to save")));
      return;
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User not logged in")));
        return;
      }

      // Upload image to Supabase Storage
      final imagePath =
          'scanned_images/${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage
          .from('scanned_images')
          .upload(
            imagePath,
            state.imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL of the image
      final imageUrl = supabase.storage
          .from('scanned_images')
          .getPublicUrl(imagePath);

      // Save data to Supabase Database
      await supabase.from('tbl_picture').insert({
        'user_uuid': user.id,
        'picture': imageUrl,
        'text_recognition': state.extractedText,
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Data saved successfully!")));

      // Navigate to saved screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SavedScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving data: $e")));
    }
  }
}
