// lib/pages/ChatPage.dart
import 'package:flutter/material.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'content': 'System initialized. Ready to analyze your datasets.'}
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat Header
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF222222))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("AI Session #402", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
              OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: kNeonGreen,
                  side: const BorderSide(color: kNeonGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text("UPLOAD DATA"),
              )
            ],
          ),
        ),

        // Messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(40),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['role'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isUser ? kNeonGreen.withOpacity(0.1) : kSurfaceBlack,
                    border: Border.all(
                      color: isUser ? kNeonGreen : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    msg['content']!,
                    style: TextStyle(
                      color: isUser ? kNeonGreen : const Color(0xFFDDDDDD),
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.all(40),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: kNeonGreen,
                  decoration: InputDecoration(
                    hintText: "Ask about your data...",
                    hintStyle: const TextStyle(color: Color(0xFF444444)),
                    filled: true,
                    fillColor: kSurfaceBlack,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: kNeonGreen),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: kNeonGreen,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: kNeonGreen.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.black),
                  onPressed: () {
                    if (_controller.text.isEmpty) return;
                    setState(() {
                      _messages.add({'role': 'user', 'content': _controller.text});
                    });
                    _controller.clear();
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}