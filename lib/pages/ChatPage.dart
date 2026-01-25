// lib/pages/ChatPage.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; 
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import 'package:dashboard_flutter/services/stats_service.dart';
import 'package:dashboard_flutter/api/api_service.dart'; 
import 'package:dashboard_flutter/services/report_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService(); 
  final ScrollController _scrollController = ScrollController(); 

  // Initial system message is hidden from UI usually, but we keep it for logic
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'content': 'System initialized. Ready.'}
  ];

  bool _isLoading = false; 
  String? _activeTool; 

  // Check if the chat is "fresh" (only has system message)
  bool get _isChatEmpty => _messages.length <= 1;

  // --- 1. HANDLE TEXT SENDING ---
  void _handleSend() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text;
    _controller.clear(); 
    
    setState(() {
      _messages.add({'role': 'user', 'content': userText});
      _isLoading = true; 
    });
    // If we were in empty state, we are now in chat state, so scroll isn't attached yet
    // Wait one frame for the list to build
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToBottom();

    StatsService().incrementQueryCount();

    final aiResponse = await _apiService.sendMessage(userText);

    if (mounted) { 
      setState(() {
        _messages.add({'role': 'ai', 'content': aiResponse});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

 // --- 2. FILE UPLOAD FLOW ---
  void _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'pdf'], 
      withData: true,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = file.name;
      String base64File = base64Encode(file.bytes!); 

      ReportService().addReport(
        fileName.split('.').first, 
        utf8.decode(file.bytes!, allowMalformed: true),
        fileName.split('.').last
      );

      setState(() {
        _messages.add({'role': 'user', 'content': '📂 Uploading $fileName...'});
        _isLoading = true;
        _activeTool = "Analyzing file structure..."; 
      });
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollToBottom();

      String analysisResult = await _apiService.processFileWithMCP(fileName, base64File);

      setState(() {
        _activeTool = "Generating insights...";
      });

      String finalAiResponse = await _apiService.sendMessage(
        "I have just run the 'upload_file' tool on '$fileName'.\n"
        "Here is the technical output from the tool:\n"
        "```\n$analysisResult\n```\n"
        "Please explain this data to me simply."
      );

      setState(() {
        _messages.add({'role': 'ai', 'content': finalAiResponse});
        _isLoading = false;
        _activeTool = null; 
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // --- HEADER (Simple) ---
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: kNeonGreen, size: 20),
                const SizedBox(width: 12),
                Text(
                  _activeTool ?? "AI Data Analyst",
                  style: TextStyle(
                    color: _activeTool != null ? kNeonGreen : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // --- MAIN CONTENT AREA ---
          Expanded(
            child: _isChatEmpty ? _buildEmptyState() : _buildChatList(),
          ),

          // --- INPUT AREA (Always at bottom) ---
          _buildInputArea(),
        ],
      ),
    );
  }

  // --- 1. THE "NEW FRESH CHAT" CENTER VIEW ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kNeonGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics_rounded, size: 64, color: kNeonGreen),
          ),
          const SizedBox(height: 32),
          const Text(
            "What data are we analyzing today?",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Upload Excel or PDF files to get started.",
            style: TextStyle(color: kTextGrey),
          ),
          const SizedBox(height: 40),
          
          // BIG UPLOAD BUTTON
          InkWell(
            onTap: _pickAndUploadFile,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: kNeonGreen, // Filled button for prominence
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(color: kNeonGreen.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4))
                ]
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload_file, color: Colors.black),
                  SizedBox(width: 12),
                  Text(
                    "Upload to Analyze File",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. THE CHAT LIST VIEW ---
  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(40),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Skip system message
        if (index == 0) return const SizedBox.shrink();

        if (index == _messages.length) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20, left: 12),
              child: SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(color: kNeonGreen, strokeWidth: 2),
              ),
            ),
          );
        }

        final msg = _messages[index];
        final isUser = msg['role'] == 'user';
        
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isUser ? kSurfaceBlack : Colors.transparent, // User bubbles are subtle
              borderRadius: BorderRadius.circular(12),
              border: isUser ? Border.all(color: Colors.white10) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: kNeonGreen),
                      SizedBox(width: 8),
                      Text("AI Analyst", style: TextStyle(color: kNeonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  msg['content']!,
                  style: TextStyle(
                    color: isUser ? Colors.white : const Color(0xFFE0E0E0),
                    height: 1.6,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 3. THE "SMOOTH" INPUT AREA ---
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900), // Limit width on large screens
          decoration: BoxDecoration(
            color: kSurfaceBlack,
            borderRadius: BorderRadius.circular(50), // Fully rounded pill
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              // Small Upload Icon inside the bar
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: kTextGrey),
                tooltip: "Upload File",
                onPressed: _isLoading ? null : _pickAndUploadFile,
              ),
              
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _handleSend(),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: kNeonGreen,
                  decoration: const InputDecoration(
                    hintText: "Ask a follow-up question...",
                    hintStyle: TextStyle(color: Color(0xFF666666)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              
              // Send Button
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: const BoxDecoration(
                  color: kNeonGreen, // Green circle
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Colors.black),
                  onPressed: _isLoading ? null : _handleSend,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}