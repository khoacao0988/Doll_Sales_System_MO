import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';

// Custom AudioSource for just_audio to play from a byte stream
class MyCustomAudioSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomAudioSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

// A simple data model for a chat message
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  final String characterId;
  final String characterName;
  final String characterImageUrl;

  const ChatScreen({
    Key? key,
    required this.characterId,
    required this.characterName,
    required this.characterImageUrl,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late final AudioPlayer _audioPlayer;
  bool _isLoading = false;

  final String backendUrl = "https://ai-character-service.onrender.com/api/chat";

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    // Add an initial greeting from the AI
    setState(() {
      _messages.add(ChatMessage(text: "Hi, tell me something!", isUser: false));
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text;
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _textController.clear();

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": text,
          "character_id": widget.characterId,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        // Play the returned audio bytes
        final audioSource = MyCustomAudioSource(response.bodyBytes);
        await _audioPlayer.setAudioSource(audioSource);
        _audioPlayer.play();
        _addBotMessage("[${widget.characterName} Replying...]");
      } else {
        _addBotMessage("Error from server: ${response.statusCode}");
      }
    } catch (e) {
      _addBotMessage("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _addBotMessage(String text) {
      setState(() {
          _messages.insert(0, ChatMessage(text: text, isUser: false));
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.characterName}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading) const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final align = message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = message.isUser ? Colors.blue.shade300 : Colors.grey.shade200;
    final textColor = message.isUser ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(message.text, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: const [BoxShadow(blurRadius: 1, color: Colors.black12, spreadRadius: 1)]),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Enter your message...',
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isLoading ? null : _sendMessage,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
