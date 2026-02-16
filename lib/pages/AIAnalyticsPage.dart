// lib/pages/AIAnalyticsPage.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import 'package:dashboard_flutter/services/report_service.dart';
import '../services/chatLimitService.dart';
import '../api/api_service.dart';
import '../components/featureFlags.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final PlatformFile? file;
  final String? tool;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.file,
    this.tool,
  });
}

class AIAnalyticsPage extends StatefulWidget {
  final ValueNotifier<String?>? contextBridge;

  const AIAnalyticsPage({super.key, this.contextBridge});

  @override
  State<AIAnalyticsPage> createState() => _AIAnalyticsPageState();
}

class _AIAnalyticsPageState extends State<AIAnalyticsPage> {
  final ApiService _api = ApiService();
  final ChatLimitService _limitService = ChatLimitService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I am your AI Financial Analyst. You can ask me to analyze data, compare dealers, or generate reports.",
      isUser: false,
    ),
  ];

  bool _isLoading = false;

  // MCP / File Context
  String? _activeFilePath;
  String? _selectedTool;
  List<dynamic> _tools = [];
  PlatformFile? _pendingFile;

  @override
  void initState() {
    super.initState();
    widget.contextBridge?.addListener(_handleIncomingContext);
    _loadTools();
  }

  @override
  void dispose() {
    widget.contextBridge?.removeListener(_handleIncomingContext);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTools() async {
    try {
      final tools = await _api.fetchTools();
      if (mounted) setState(() => _tools = tools);
    } catch (e) {
      debugPrint("Failed to load tools: $e");
    }
  }

  void _handleIncomingContext() {
    final incomingMsg = widget.contextBridge?.value;
    if (incomingMsg != null && incomingMsg.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(text: incomingMsg, isUser: false));
        _messages.add(
          ChatMessage(
            text: "What specific details would you like to dive into?",
            isUser: false,
          ),
        );
      });
      _scrollToBottom();
      widget.contextBridge?.value = null;
    }
  }

  // --- OPEN BOTTOM SHEET TO PICK FILE OR TOOL ---
  void _openComposer() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: kBankSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _Composer(
        tools: _tools,
        onFilePicked: (file) => _pendingFile = file,
        onToolSelected: (tool) => _selectedTool = tool,
      ),
    );
    setState(() {}); // Refresh UI to show preview chips
  }

  // --- SEND MESSAGE & UPLOAD FILE ---
  Future<void> _sendMessage() async {
    final userText = _msgController.text.trim();
    if (userText.isEmpty && _pendingFile == null) return;

    final canSend = await _limitService.canSendMessage();
    if (!canSend) {
      _showLimitDialog();
      return; 
    }

    _msgController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: userText, 
          isUser: true, 
          file: _pendingFile, 
          tool: _selectedTool
        )
      );
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // 1. Upload File (if new one provided)
      if (_pendingFile != null && _pendingFile!.bytes != null) {
        final base64File = base64Encode(_pendingFile!.bytes!);
        _activeFilePath = await _api.uploadDataset(
          _pendingFile!.name,
          base64File,
        );
      }

      // 2. Construct Message with Context
      String finalMessage = userText;
      if (_selectedTool != null) {
        finalMessage = "Using the tool '$_selectedTool', please $userText";
      }

      // 3. Send to API
      final response = await _api.sendChat(
        message: finalMessage,
        csvFilePath: _activeFilePath,
      );

      await _limitService.incrementMessageCount();

      setState(() {
        _messages.add(
          ChatMessage(
            text: response['response'] ?? "I couldn't process that.",
            isUser: false,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(text: "Error connecting to AI backend: $e", isUser: false),
        );
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

  void _openSavedReports() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: kBankSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Saved Reports",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextWhite,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<Report>>(
                valueListenable: ReportService().reportsNotifier,
                builder: (context, reports, child) {
                  if (reports.isEmpty) {
                    return const Center(
                      child: Text(
                        "No saved reports.",
                        style: TextStyle(color: kTextGrey),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return ListTile(
                        tileColor: kBankBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: kBorderColor),
                        ),
                        leading: const Icon(Icons.table_chart_rounded, color: kBankPrimary),
                        title: Text(report.name, style: const TextStyle(color: kTextWhite)),
                        subtitle: Text(report.size, style: const TextStyle(color: kTextGrey)),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_rounded, color: kSuccessGreen),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Downloading ${report.name}')),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kBankSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text("Limit Reached", style: TextStyle(color: kTextWhite)),
          ],
        ),
        content: const Text(
          "Daily free limit expired.\nPlease recharge or wait 24 hrs.",
          style: TextStyle(color: kTextGrey, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: kTextGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); 
              final url = Uri.parse("https://google.com"); 
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kBankPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Recharge Now"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!FeatureFlags.enableAiAssistant) {
      return Scaffold(
        backgroundColor: kBankBg,
        appBar: AppBar(
          backgroundColor: kBankBg,
          elevation: 0,
          title: const Text("AI Analyst", style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_special_rounded, color: kBankPrimary),
              tooltip: "Saved Reports",
              onPressed: _openSavedReports,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: kBankSurface, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, size: 48, color: kTextGrey),
              ),
              const SizedBox(height: 24),
              const Text("AI Analyst Offline", style: TextStyle(color: kTextWhite, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("The AI is currently undergoing maintenance.\nPlease check back later.", textAlign: TextAlign.center, style: TextStyle(color: kTextGrey, height: 1.5)),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: kBankBg,
      appBar: AppBar(
        backgroundColor: kBankBg,
        elevation: 0,
        title: const Text("AI Analyst", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_special_rounded, color: kBankPrimary),
            tooltip: "Saved Reports",
            onPressed: _openSavedReports,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildChatBubble(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 12, height: 12, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: kBankPrimary)
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Analyzing data...",
                      style: TextStyle(color: kTextGrey, fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? kBankPrimary.withOpacity(0.2) : kBankSurfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
            bottomRight: Radius.circular(msg.isUser ? 0 : 16),
          ),
          border: Border.all(
            color: msg.isUser ? kBankPrimary.withOpacity(0.5) : kBorderColor,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.file != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kBankPrimary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.insert_drive_file_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        msg.file!.name,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            if (msg.tool != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "Tool Requested: ${msg.tool}",
                  style: const TextStyle(color: kTextGrey, fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
            SelectableText(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? kBankPrimary : kTextWhite,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: kBankSurface,
        border: Border(top: BorderSide(color: kBorderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PREVIEW CHIPS FOR PENDING ATTACHMENTS
          if (_pendingFile != null || _selectedTool != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_pendingFile != null)
                    _PreviewChip(
                      icon: Icons.file_present_rounded,
                      label: _pendingFile!.name,
                      onRemove: () => setState(() => _pendingFile = null),
                    ),
                  if (_selectedTool != null)
                    _PreviewChip(
                      icon: Icons.build_circle_outlined,
                      label: "Tool: $_selectedTool",
                      onRemove: () => setState(() => _selectedTool = null),
                    ),
                ],
              ),
            ),
          
          // INPUT FIELD
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(color: kBankSurfaceLight, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.add_rounded, color: kTextGrey, size: 22),
                  onPressed: _openComposer,
                  tooltip: "Attach File / Tool",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _msgController,
                  style: const TextStyle(color: kTextWhite),
                  decoration: InputDecoration(
                    hintText: "Ask about a dealer or trend...",
                    hintStyle: const TextStyle(color: kTextGrey),
                    filled: true,
                    fillColor: kBankBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: const BoxDecoration(color: kBankPrimary, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* =============================
 * SUPPORTING COMPONENTS
 * ============================= */

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
      case 'describe_dataset': return 'Describe Dataset';
      case 'get_correlation_matrix': return 'Correlation Matrix';
      case 'get_normal_distribution': return 'Distribution Curve';
      case 'python_repl_ast': return 'General Statistical Analysis';
      default: return rawName.replaceAll('_', ' ').toUpperCase();
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
            title: const Text("Upload Dataset", style: TextStyle(color: kTextWhite, fontWeight: FontWeight.w600)),
            subtitle: const Text("Support for Excel, PDF", style: TextStyle(color: kTextGrey)),
            onTap: () async {
              // --- 1. CROSS-PLATFORM PERMISSION CHECK ---
              // Only ask for permissions if NOT on Web AND on Android
              if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;
                
                // Only Android 12 and below need explicit sweeping storage permissions
                if (androidInfo.version.sdkInt < 33) {
                  final status = await Permission.storage.request();
                  if (!status.isGranted) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Storage permission required to upload files.")),
                      );
                    }
                    return; // Stop if permission denied
                  }
                }
              }

              // --- 2. PICK THE FILE ---
              // This works seamlessly on Web, iOS, and Android
              final res = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['xlsx', 'pdf'],
                withData: true, // Crucial for Web to get file bytes for base64 encoding
              );

              if (res != null && res.files.isNotEmpty) {
                onFilePicked(res.files.first);
              }
              
              if (context.mounted) Navigator.pop(context); // Close bottom sheet
            },
          ),

          if (tools.isNotEmpty) ...[
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
          ]
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  const _PreviewChip({required this.icon, required this.label, required this.onRemove});

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
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: kTextWhite, fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
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