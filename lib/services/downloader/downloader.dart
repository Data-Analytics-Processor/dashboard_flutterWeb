// lib/services/downloader/downloader.dart

// By default, use the mobile stub (safe for Android/iOS)
// If the platform is Web (dart.library.html is available), use the web implementation.
export 'mobile_download.dart'
  if (dart.library.html) 'web_download.dart';