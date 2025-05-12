import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scanner/presentation/cubit/scanner_cubit.dart';
import 'package:scanner/presentation/cubit/scanner_state.dart';
import 'package:share_plus/share_plus.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apatu Scanner'),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/profile');
            },
            icon: Icon(Icons.person_2_rounded),
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => ScannerCubit(),
        child: ScannerView(),
      ),
      //todo: don't add button with no function
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.list),
      // ),
    );
  }
}

class ScannerView extends StatelessWidget {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScannerCubit, ScannerState>(
      listener: (context, state) {
        // Optional: Show a snackbar or handle additional side effects
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                state.imageFile == null
                    ? Text('Select an image to analyze')
                    : Image.file(
                      state.imageFile!,
                      height: 200,
                      width: double.infinity,
                    ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<ScannerCubit>().pickImage();
                  },
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    state.extractedText.isNotEmpty
                        ? state.extractedText
                        : 'Extracted text will appear here',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                if (state.imageFile != null &&
                    state.extractedText.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<ScannerCubit>().saveToSupabase(context);
                        },
                        child: Text('Save'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final text = state.extractedText;
                          if (text.isNotEmpty) {
                            SharePlus.instance.share(ShareParams(text: text));
                          }
                        },
                        icon: Icon(Icons.share),
                        label: Text('Share'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
