// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ApiService {
  final String _baseUrl = "https://dap-backend-go.onrender.com";
  final String _mcpBaseUrl = "https://mcphelperpy.onrender.com";

  // Generate a unique ID for this session
  final String _sessionId = const Uuid().v4();

  // --- 1. CHAT (Talks to Go Backend) ---
  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'conversation_id': _sessionId, // Identify this user session
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? "No response from AI.";
      } else {
        return "Error: Server returned ${response.statusCode}";
      }
    } catch (e) {
      return "Connection Error: $e";
    }
  }

  // --- 2. TOOLS (Talks to Python MCP) ---
  Future<String> processFileWithMCP(String fileName, String base64Content) async {
    try {
      // CHANGED: We now hit the custom "Direct Bridge" endpoint
      final url = '$_mcpBaseUrl/api/simple-upload';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "filename": fileName,
          "file_base64": base64Content
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // The Python API returns { "status": "success", "analysis": "..." }
        return data['analysis'] ?? "No analysis returned.";
      } else {
        return "Error: Python Server returned ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Could not connect to Analysis Tools. (Error: $e)";
    }
  }

  // Helper to send file content 
  Future<String> sendFileContext(String fileName, String fileContent) async {
    // We wrap the file content in a prompt so the AI knows what to do
    final prompt =
        """
        I am uploading a file named '$fileName'. 
        Here is the data content:
        $fileContent

        Please analyze this data and give me a brief summary of what it contains.
        """;
    return sendMessage(prompt);
  }
}
