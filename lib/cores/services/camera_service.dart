import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraService {
  static final ImagePicker _picker =
      ImagePicker();

  static Future<File?> takePhoto() async {
    final XFile? file =
        await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (file == null) return null;

    return File(file.path);
  }
}