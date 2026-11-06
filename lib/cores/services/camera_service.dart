import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  /// Prendre une photo avec l'appareil photo
  static Future<File?> takePhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (file == null) return null;

    return File(file.path);
  }

  /// Choisir une photo depuis la galerie
  static Future<File?> pickFromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) return null;

    return File(file.path);
  }

  /// Dialogue de sélection (Appareil photo ou Galerie) et renvoie le chemin du fichier
  static Future<String?> pickImage(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text("Prendre une photo"),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text("Choisir depuis la galerie"),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == 'camera') {
      final f = await takePhoto();
      return f?.path;
    } else if (choice == 'gallery') {
      final f = await pickFromGallery();
      return f?.path;
    }
    return null;
  }
}