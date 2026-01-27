import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import 'package:dashboard_flutter/api/api_service.dart';
import 'package:dashboard_flutter/services/report_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ApiService _api = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  bool _isLoading = false;

  // MCP context
  String? _activeFilePath; // The file currently being analyzed
  String? _selectedTool; // User's manual tool override (optional)
  List<dynamic> _tools = [];

  // Pending upload (before send)
  PlatformFile? _pendingFile;

  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadTools();
  }

  Future<void> _loadTools() async {
    try {
      final tools = await _api.fetchTools();
      setState(() => _tools = tools);
    } catch (e) {
      // Handle error silently or log
    }
  }

  /* -----------------------------
   * PLUS BUTTON → COMPOSER
   * ----------------------------- */
  void _openComposer() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: kBankSurface, // Theme Update
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _Composer(
        tools: _tools,
        onFilePicked: (file) => _pendingFile = file,
        onToolSelected: (tool) => _selectedTool = tool,
      ),
    );

    setState(() {});
  }

  /* -----------------------------
   * SEND MESSAGE (ONE SHOT)
   * ----------------------------- */
  Future<void> _handleSend() async {
    final userText = _textController.text.trim();
    if (_pendingFile == null && userText.isEmpty) return;

    _textController.clear();

    // 1. Add User Message to UI
    setState(() {
      _messages.add(
        _ChatMessage.user(
          text: userText,
          file: _pendingFile,
          tool: _selectedTool,
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // 2. Upload File (if new one provided)
      if (_pendingFile != null) {
        final base64File = base64Encode(_pendingFile!.bytes!);
        // The API now returns the server-side file path
        _activeFilePath = await _api.uploadDataset(
          _pendingFile!.name,
          base64File,
        );
      }

      // 3. Construct Message with Context
      // If user selected a tool explicitly, we guide the Agent.
      String finalMessage = userText;
      if (_selectedTool != null) {
        finalMessage = "Using the tool '$_selectedTool', please $userText";
      }

      // 4. Send to Backend Brain (Agent)
      final result = await _api.sendChat(
        message: finalMessage,
        csvFilePath: _activeFilePath, // Pass the active file path
      );

      // 5. Add AI Response to UI
      setState(() {
        _messages.add(
          _ChatMessage.ai(result["response"] ?? "No response generated."),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage.ai("⚠️ Error: $e"));
      });
    } finally {
      setState(() {
        _isLoading = false;
        _pendingFile = null;
        _selectedTool = null;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /* -----------------------------
   * UI
   * ----------------------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBankBg, // Theme Update
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildChat()),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: kBankBg,
        border: Border(bottom: BorderSide(color: kBorderColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBankPrimary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: kBankPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          const Text("Nova Analyst", style: TextStyle(color: kTextWhite, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildChat() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return const _TypingIndicator();
        }
        if (index >= _messages.length) return const SizedBox.shrink();
        return _messages[index].build(context);
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: kBankBg,
        border: Border(top: BorderSide(color: kBorderColor)),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: kBankSurface, // Theme Update
            borderRadius: BorderRadius.circular(30), // Pill Shape
            border: Border.all(color: kBorderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 PREVIEW ROW (file + tool)
              if (_pendingFile != null || _selectedTool != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_pendingFile != null)
                        _PreviewChip(
                          icon: Icons.insert_drive_file_rounded,
                          label: _pendingFile!.name,
                          onRemove: () {
                            setState(() => _pendingFile = null);
                          },
                        ),
                      if (_selectedTool != null)
                        _PreviewChip(
                          icon: Icons.analytics_rounded,
                          label: "Tool: $_selectedTool",
                          onRemove: () {
                            setState(() => _selectedTool = null);
                          },
                        ),
                    ],
                  ),
                ),

              // 🔹 INPUT ROW
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: kTextGrey),
                    onPressed: _openComposer,
                    tooltip: "Upload or Select Tool",
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: kTextWhite),
                      cursorColor: kBankPrimary,
                      decoration: const InputDecoration(
                        hintText: "Add instructions...",
                        hintStyle: TextStyle(color: kTextGrey),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isLoading ? null : _handleSend,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kBankPrimary, // Theme Update
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: kBankPrimary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))
                        ]
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =============================
 * SUPPORTING WIDGETS
 * ============================= */

class _ChatMessage {
  final bool isUser;
  final String text;
  final PlatformFile? file;
  final String? tool;

  _ChatMessage.user({required this.text, this.file, this.tool}) : isUser = true;

  _ChatMessage.ai(this.text) : isUser = false, file = null, tool = null;

  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        constraints: const BoxConstraints(maxWidth: 700),
        child: isUser ? _buildUserMessage() : _buildAiMessage(context),
      ),
    );
  }

  Widget _buildUserMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBankPrimary, // Theme Update: User is Blue
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(color: kBankPrimary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (file != null) _FileChip(file!.name, isUser: true),
          if (tool != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "Requested Tool: $tool",
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          Text(text, style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildAiMessage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBankSurface, // Theme Update: AI is Dark Surface
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: kBankSurfaceLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: kBankPrimary),
                const SizedBox(width: 8),
                const Text("Analysis Result", style: TextStyle(color: kTextGrey, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              text,
              style: const TextStyle(
                color: kTextWhite,
                height: 1.6,
                fontSize: 15,
              ),
            ),
          ),

          const Divider(height: 1, color: kBorderColor),

          // Footer with Save Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // SAVE LOGIC
                    final name = "Report_${DateFormat('dd_MMM_yy_HH_mm').format(DateTime.now())}";

                    ReportService().addReport(name, text, "txt");

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Saved '$name' to Reports"),
                        backgroundColor: kBankPrimary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(milliseconds: 1500),
                        action: SnackBarAction(
                          label: "VIEW",
                          textColor: Colors.white,
                          onPressed: () {
                            // Navigation logic would go here if needed
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_alt_rounded, size: 16),
                  label: const Text("Save Report"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kTextWhite,
                    side: const BorderSide(color: kBorderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  final String name;
  final bool isUser;
  const _FileChip(this.name, {this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUser ? Colors.white24 : kBankSurfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_rounded, size: 14, color: isUser ? Colors.white : kBankPrimary),
          const SizedBox(width: 6),
          Text(name, style: TextStyle(color: isUser ? Colors.white : kTextWhite, fontSize: 12)),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 16),
      child: Row(
        children: const [
          SizedBox(
            width: 8,
            height: 8,
            child: CircularProgressIndicator(strokeWidth: 2, color: kBankPrimary),
          ),
          SizedBox(width: 12),
          Text("Analyzing data...", style: TextStyle(color: kTextGrey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final List<dynamic> tools;
  final Function(PlatformFile) onFilePicked;
  final Function(String) onToolSelected;

  const _Composer({
    required this.tools,
    required this.onFilePicked,
    required this.onToolSelected,
  });

  String _formatToolName(String rawName) {
    switch (rawName) {
      case 'describe_dataset':
        return 'Describe Dataset';
      case 'get_correlation_matrix':
        return 'Correlation Matrix';
      case 'get_normal_distribution':
        return 'Distribution Curve';
      case 'python_repl_ast':
        return 'General Statistical Analysis';
      default:
        return rawName.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Attach Context", style: TextStyle(color: kTextWhite, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: kBankPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.upload_file_rounded, color: kBankPrimary),
            ),
            title: const Text(
              "Upload Dataset",
              style: TextStyle(color: kTextWhite, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text("Support for CSV, Excel", style: TextStyle(color: kTextGrey)),
            onTap: () async {
              final res = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['xlsx', 'xls', 'csv'],
                withData: true,
              );
              if (res != null) onFilePicked(res.files.first);
              Navigator.pop(context);
            },
          ),

          const Divider(color: kBorderColor, height: 30),
          const Text("Analysis Tools", style: TextStyle(color: kTextGrey, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          ...tools.map(
            (t) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.analytics_outlined, color: kTextGrey, size: 20),
              title: Text(
                _formatToolName(t["name"]),
                style: const TextStyle(color: kTextWhite, fontSize: 14),
              ),
              onTap: () {
                onToolSelected(t["name"]);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  const _PreviewChip({
    required this.icon,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kBankSurfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kBankPrimary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: kTextWhite, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 16, color: kTextGrey),
          ),
        ],
      ),
    );
  }
}