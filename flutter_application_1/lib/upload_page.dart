import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _imageFile;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path); // Fixed assignment
      });
    }
  }

  Future<void> uploadImage() async {
    if (_imageFile == null) return;

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    try {
      await Supabase.instance.client.storage.from('images').upload(path, _imageFile!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image upload successful!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _imageFile != null
              ? Image.file(_imageFile!)
              : const Text("No Image Selected"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: pickImage,
            child: const Text('Pick Image'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: uploadImage,
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
