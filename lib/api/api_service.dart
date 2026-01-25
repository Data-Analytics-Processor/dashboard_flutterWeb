// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ApiService {
  final String _goBaseUrl = "https://dap-backend-go.onrender.com";
  //final String _goBaseUrl = "http://localhost:8080";

  final String _mcpBaseUrl = "https://mcphelperpy.onrender.com";
  //final String _mcpBaseUrl = "http://127.0.0.1:8000";

  final String _sessionId = const Uuid().v4();

  /* -----------------------------
   * 1. MCP: LIST TOOLS
   * ----------------------------- */
  Future<List<dynamic>> fetchTools() async {
    final res = await http.get(Uri.parse("$_mcpBaseUrl/tools"));

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch tools");
    }

    final data = jsonDecode(res.body);
    return data["tools"];
  }

  /* -----------------------------
   * 2. MCP: UPLOAD DATASET
   * ----------------------------- */
  Future<Map<String, dynamic>> uploadDataset(
    String filename,
    String base64Content,
  ) async {
    final res = await http.post(
      Uri.parse("$_mcpBaseUrl/upload"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"filename": filename, "file_base64": base64Content}),
    );

    if (res.statusCode != 200) {
      throw Exception("Dataset upload failed: ${res.body}");
    }

    return jsonDecode(res.body);
  }

  /* -----------------------------
   * 3. MCP: EXECUTE TOOL
   * ----------------------------- */
  Future<Map<String, dynamic>> executeTool({
    required String datasetId,
    required String tool,
    Map<String, dynamic> args = const {},
  }) async {
    final res = await http.post(
      Uri.parse("$_mcpBaseUrl/execute"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"dataset_id": datasetId, "tool": tool, "args": args}),
    );

    if (res.statusCode != 200) {
      throw Exception("Tool execution failed: ${res.body}");
    }

    return jsonDecode(res.body);
  }

  /* -----------------------------
   * 4. GO BACKEND: EXPLAIN RESULT
   * ----------------------------- */
  Future<String> explainResult({
    required String userIntent,
    required String toolName,
    required Map<String, dynamic> toolResult,
  }) async {
    final res = await http.post(
      Uri.parse("$_goBaseUrl/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "conversation_id": _sessionId,
        "message":
            """
User intent:
$userIntent

Selected tool:
$toolName

Tool output (JSON):
${jsonEncode(toolResult)}

Instructions:
- Analyze the result
- Explain clearly
- Do NOT ask follow-up questions
""",
      }),
    );

    if (res.statusCode != 200) {
      return "AI explanation failed (${res.statusCode})";
    }

    final data = jsonDecode(res.body);
    return data["reply"] ?? "No explanation generated.";
  }
}
