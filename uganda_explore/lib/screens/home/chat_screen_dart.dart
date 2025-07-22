import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<List<Map<String, dynamic>>> chatHistories = [];
  List<Map<String, dynamic>> currentChat = [];
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;
  bool aiTyping = false;

  // Save the current chat to history and start a new chat
  void saveCurrentChat() {
    if (currentChat.isNotEmpty) {
      setState(() {
        chatHistories.insert(0, List<Map<String, dynamic>>.from(currentChat));
        currentChat.clear();
      });
    }
  }

  Future<String> fetchAIResponse(String prompt) async {
    setState(() {
      aiTyping = true;
    });
    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization':
            'Bearer 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',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "openai/gpt-3.5-turbo",
        "messages": [
          for (final msg in currentChat)
            {"role": msg['role'], "content": msg['text']},
          {"role": "user", "content": prompt},
        ],
      }),
    );

    setState(() {
      aiTyping = false;
    });

    // Debug: Print the full response for troubleshooting
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else if (response.statusCode == 401) {
      return 'Authentication failed: Please check your API key and try again.';
    } else {
      return 'Sorry, I could not get a response. Please try again.';
    }
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final now = DateTime.now();
    setState(() {
      currentChat.add({
        'role': 'user',
        'text': text,
        'timestamp': now,
        'seen': true,
      });
      isLoading = true;
    });
    final aiResponse = await fetchAIResponse(text);
    final aiNow = DateTime.now();
    setState(() {
      currentChat.add({
        'role': 'ai',
        'text': aiResponse,
        'timestamp': aiNow,
        'seen': true,
      });
      isLoading = false;
    });
  }

  String formatTimestamp(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void openHistoryChat(List<Map<String, dynamic>> chat) {
    setState(() {
      currentChat = List<Map<String, dynamic>>.from(chat);
    });
    Navigator.of(context).pop();
  }

  void showHistoryDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        height: 420,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Chat History",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
            Expanded(
              child: chatHistories.isEmpty
                  ? const Center(
                      child: Text(
                        "No chat history yet.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: chatHistories.length,
                      itemBuilder: (context, idx) {
                        final chat = chatHistories[idx];
                        final preview = chat.isNotEmpty
                            ? chat.first['text'].toString().substring(
                                0,
                                chat.first['text'].toString().length > 30
                                    ? 30
                                    : chat.first['text'].toString().length,
                              )
                            : '';
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF3B82F6),
                              child: Text(
                                "${chatHistories.length - idx}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text("Chat #${chatHistories.length - idx}"),
                            subtitle: Text(preview),
                            onTap: () => openHistoryChat(chat),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextButton.icon(
                icon: const Icon(Icons.add_comment, color: Color(0xFF3B82F6)),
                label: const Text(
                  "Start New Chat",
                  style: TextStyle(color: Color(0xFF3B82F6)),
                ),
                onPressed: () {
                  saveCurrentChat();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E3D4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              'Virtual Guide Chat',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.history, color: Color(0xFF3B82F6)),
              tooltip: "Chat History",
              onPressed: showHistoryDialog,
            ),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3B82F6)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE5E3D4), Color(0xFFB3C6E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: currentChat.length,
                itemBuilder: (context, idx) {
                  final msg = currentChat[idx];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF3B82F6) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isUser ? 24 : 8),
                          topRight: Radius.circular(isUser ? 8 : 24),
                          bottomLeft: const Radius.circular(24),
                          bottomRight: const Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.09),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: isUser
                              ? const Color(0xFF3B82F6)
                              : Colors.grey.shade200,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['text'] ?? '',
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatTimestamp(msg['timestamp'] as DateTime),
                                style: TextStyle(
                                  color: isUser
                                      ? Colors.white70
                                      : Colors.black45,
                                  fontSize: 11,
                                ),
                              ),
                              if (msg['role'] == 'ai' || msg['role'] == 'user')
                                Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: Icon(
                                    msg['seen'] == true
                                        ? Icons.done_all
                                        : Icons.done,
                                    size: 14,
                                    color: msg['seen'] == true
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (aiTyping)
              Padding(
                padding: const EdgeInsets.only(left: 18, bottom: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "AI is typing...",
                      style: TextStyle(
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Ask about any tourism site...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (val) {
                          sendMessage(val);
                          controller.clear();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      sendMessage(controller.text);
                      controller.clear();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
