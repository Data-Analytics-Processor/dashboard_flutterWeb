// lib/services/downloader/mobile_download.dart

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Saves the file to the device's Downloads folder (Android) or Documents (iOS).
Future<void> downloadFile(List<int> bytes, String fileName, String mimeType) async {
  try {
    if (Platform.isAndroid) {
      // --- 1. Android Permission Logic ---
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt < 33) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            debugPrint("Permission denied: Cannot save file.");
            return;
          }
        }
      }

      // --- 2. Determine Path (Public Downloads Folder) ---
      Directory directory = Directory('/storage/emulated/0/Download');
      
      if (!await directory.exists()) {
        directory = (await getExternalStorageDirectory()) ?? await getApplicationDocumentsDirectory();
      }

      final String savePath = "${directory.path}/$fileName";
      final File file = File(savePath);

      // --- 3. Write File ---
      await file.writeAsBytes(bytes);
      
      debugPrint("File saved successfully to: $savePath");
      
    } else if (Platform.isIOS) {
      // --- iOS Logic ---
      // Saves to App Documents. User can access via the "Files" app 
      final directory = await getApplicationDocumentsDirectory();
      final String savePath = "${directory.path}/$fileName";
      final File file = File(savePath);
      
      await file.writeAsBytes(bytes);
      debugPrint("File saved successfully to: $savePath");
    }
  } catch (e) {
    debugPrint("Download failed: $e");
  }
}