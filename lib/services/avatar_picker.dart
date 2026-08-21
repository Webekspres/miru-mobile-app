import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../config/theme.dart';

Future<File?> pickAndCropAvatar(BuildContext context) async {
  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 95,
  );
  if (picked == null) return null;

  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 90,
    maxWidth: 1024,
    maxHeight: 1024,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Potong foto',
        toolbarColor: AppTheme.primaryColor,
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: AppTheme.primaryColor,
        backgroundColor: Colors.black,
        cropStyle: CropStyle.circle,
        lockAspectRatio: true,
        hideBottomControls: false,
        aspectRatioPresets: [CropAspectRatioPreset.square],
      ),
      IOSUiSettings(
        title: 'Potong foto',
        doneButtonTitle: 'Simpan',
        cancelButtonTitle: 'Batal',
        cropStyle: CropStyle.circle,
        aspectRatioLockEnabled: true,
        aspectRatioPresets: [CropAspectRatioPreset.square],
      ),
    ],
  );
  if (cropped == null) return null;
  return File(cropped.path);
}
