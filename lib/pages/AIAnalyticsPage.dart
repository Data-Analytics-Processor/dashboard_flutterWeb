// lib/pages/AIAnalyticsPage.dart
import 'package:flutter/material.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import 'package:dashboard_flutter/services/report_service.dart';
import '../api/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class AIAnalyticsPage extends StatefulWidget {
  final ValueNotifier<String?>? contextBridge;

  const AIAnalyticsPage({super.key, this.contextBridge});

  @override
  State<AIAnalyticsPage> createState() => _AIAnalyticsPageState();
}

class _AIAnalyticsPageState extends State<AIAnalyticsPage> {
  final ApiService _api = ApiService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello! I am your AI Financial Analyst. You can ask me to analyze data, compare dealers, or generate reports.", isUser: false)
  ];
  
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Listen for incoming context from the Insights Page Bottom Sheet
    widget.contextBridge?.addListener(_handleIncomingContext);
  }

  @override
  void dispose() {
    widget.contextBridge?.removeListener(_handleIncomingContext);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleIncomingContext() {
    final incomingMsg = widget.contextBridge?.value;
    if (incomingMsg != null && incomingMsg.isNotEmpty) {
      setState(() {
        // Add the summary we generated in the bottom sheet to the chat visually
        _messages.add(ChatMessage(text: incomingMsg, isUser: false));
        _messages.add(ChatMessage(text: "What specific details would you like to dive into for this dealer?", isUser: false));
      });
      _scrollToBottom();
      widget.contextBridge?.value = null; // Clear the bridge
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    
    _msgController.clear();
    _scrollToBottom();

    try {
      final response = await _api.sendChat(message: text);
      setState(() {
        _messages.add(ChatMessage(text: response['response'] ?? "I couldn't process that.", isUser: false));
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Error connecting to AI backend.", isUser: false));
        _isTyping = false;
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

  // --- Keeps your old Saved Reports logic safe ---
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
            const Text("Saved Reports", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextWhite)),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<Report>>(
                valueListenable: ReportService().reportsNotifier,
                builder: (context, reports, child) {
                  if (reports.isEmpty) {
                    return const Center(child: Text("No saved reports.", style: TextStyle(color: kTextGrey)));
                  }
                  return ListView.separated(
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return ListTile(
                        tileColor: kBankBg,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: kBorderColor)),
                        leading: const Icon(Icons.table_chart_rounded, color: kBankPrimary),
                        title: Text(report.name, style: const TextStyle(color: kTextWhite)),
                        subtitle: Text(report.size, style: const TextStyle(color: kTextGrey)),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_rounded, color: kSuccessGreen),
                          // Replace with your actual download logic
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading ${report.name}'))),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("AI is thinking...", style: TextStyle(color: kTextGrey, fontStyle: FontStyle.italic, fontSize: 12)),
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
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? kBankPrimary.withOpacity(0.2) : kBankSurfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
            bottomRight: Radius.circular(msg.isUser ? 0 : 16),
          ),
          border: Border.all(color: msg.isUser ? kBankPrimary.withOpacity(0.5) : kBorderColor),
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: msg.isUser ? kBankPrimary : kTextWhite, fontSize: 14, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: kBankSurface,
        border: Border(top: BorderSide(color: kBorderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              style: const TextStyle(color: kTextWhite),
              decoration: InputDecoration(
                hintText: "Ask about a dealer or trend...",
                hintStyle: const TextStyle(color: kTextGrey),
                filled: true,
                fillColor: kBankBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
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
          )
        ],
      ),
    );
  }
}