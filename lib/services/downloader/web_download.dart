import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart';

Future<void> downloadFile(List<int> bytes, String fileName, String mimeType) async {

  final data = Uint8List.fromList(bytes);

  final blob = Blob(
    [data.toJS].toJS, 
    BlobPropertyBag(type: mimeType)
  );

  // 3. Create an Object URL for the Blob
  final url = URL.createObjectURL(blob);

  // 4. Create an HTML Anchor (<a>) element
  final anchor = document.createElement('a') as HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.style.display = 'none';

  // 5. Append to body, click, and clean up
  document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  // 6. Revoke URL to free memory
  URL.revokeObjectURL(url);
}