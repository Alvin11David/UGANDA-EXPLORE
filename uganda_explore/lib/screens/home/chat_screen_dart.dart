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
      builder: (context) => SizedBox(
        height: 400,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Chat History",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: chatHistories.isEmpty
                  ? const Center(child: Text("No chat history yet."))
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
                        return ListTile(
                          title: Text("Chat #${chatHistories.length - idx}"),
                          subtitle: Text(preview),
                          onTap: () => openHistoryChat(chat),
                        );
                      },
                    ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add_comment),
              label: const Text("Start New Chat"),
              onPressed: () {
                saveCurrentChat();
                Navigator.of(context).pop();
              },
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
        backgroundColor: const Color(0xFF3B82F6),
        title: Row(
          children: [
            const Icon(Icons.smart_toy, color: Colors.greenAccent, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Virtual Guide Chat',
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
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
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
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
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF3B82F6) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatTimestamp(msg['timestamp'] as DateTime),
                              style: TextStyle(
                                color: isUser ? Colors.white70 : Colors.black45,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about any tourism site...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    sendMessage(controller.text);
                    controller.clear();
                  },
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
