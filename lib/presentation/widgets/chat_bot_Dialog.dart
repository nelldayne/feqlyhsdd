import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qlyhoso/services/gemini_serviecs.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ChatbotScreenState createState() => ChatbotScreenState();
}

class ChatbotScreenState extends State<ChatbotScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _chatController = TextEditingController();
  final GeminiService geminiService = GeminiService();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> chatMessages = [
    {
      "sender": "bot",
      "message": "Xin chào! Tôi có thể giúp gì cho bạn hôm nay?",
      "timestamp": DateTime.now().toIso8601String(),
    }
  ];

  final List<String> predefinedQuestions = [
    "Tôi cần hỗ trợ về cách sử dụng ứng dụng.",
    "Làm thế nào để tra cứu thông tin thửa đất?",
    "Tôi gặp lỗi khi đăng nhập, làm sao để khắc phục?",
    "Ứng dụng bị chậm, có cách nào cải thiện không?",
  ];

  bool isTyping = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      chatMessages.add({
        "sender": "user",
        "message": message,
        "timestamp": DateTime.now().toIso8601String(),
      });
      isTyping = true;
    });
    _scrollToBottom();
    _chatController.clear();
    await Future.delayed(const Duration(seconds: 1));

    String botResponse = await geminiService.sendMessage(message);

    setState(() {
      isTyping = false;
      chatMessages.add({
        "sender": "bot",
        "message": botResponse,
        "timestamp": DateTime.now().toIso8601String(),
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: const Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      height: MediaQuery.of(context).size.height * 0.95,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Chat Hỗ Trợ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Danh sách tin nhắn
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatMessages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatMessages.length && isTyping) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Đang nhập",
                            style: TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                          SizedBox(width: 5),
                          _TypingIndicator(),
                        ],
                      ),
                    ),
                  );
                }

                final message = chatMessages[index];
                final isUser = message["sender"] == "user";
                final timestamp = DateTime.parse(message["timestamp"]);
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isUser ? const Color(0xFF2196F3) : Colors.grey[100],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
                            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
                          ),
                        ),
                        child: message.containsKey("imagePath")
                            ? Image.file(File(message["imagePath"]))
                            : Text(
                          message["message"]!,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Câu hỏi thường gặp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Câu hỏi thường gặp",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: predefinedQuestions.length,
                    itemBuilder: (context, index) {
                      final question = predefinedQuestions[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          label: Text(
                            question,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                          pressElevation: 4,
                          onPressed: () => _sendMessage(question),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Ô nhập tin nhắn
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: () {
                    // TODO: Thêm logic đính kèm file (nếu cần)
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _sendMessage(_chatController.text),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2196F3),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 24),
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

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dot1;
  late Animation<double> _dot2;
  late Animation<double> _dot3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _dot1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.33, curve: Curves.easeInOut)),
    );
    _dot2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.33, 0.66, curve: Curves.easeInOut)),
    );
    _dot3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.66, 1.0, curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _dot1,
          builder: (context, child) => Opacity(
            opacity: _dot1.value,
            child: const Text(
              ".",
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _dot2,
          builder: (context, child) => Opacity(
            opacity: _dot2.value,
            child: const Text(
              ".",
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _dot3,
          builder: (context, child) => Opacity(
            opacity: _dot3.value,
            child: const Text(
              ".",
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}