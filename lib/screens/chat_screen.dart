import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

// Custom AudioSource to play from a byte stream
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
  late final AudioPlayer _audioPlayer;
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isLoading = false;
  String _statusText = "";
  String _recognizedWords = "";

  final String backendUrl = "https://ai-character-service.onrender.com/api/chat";

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initSpeech();
    // Listen to player state to update UI
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed ||
          state.processingState == ProcessingState.ready) {
        if (!_isListening) {
          setState(() {
            _statusText = "Nhấn vào micro để nói";
          });
        }
      }
    });
    setState(() {
      _statusText = "Nhấn vào micro để nói";
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: "vi_VN",
    );
    if (!mounted) return;
    setState(() {
      _isListening = true;
      _statusText = "Đang nghe...";
    });
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    if (!mounted) return;
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() {
      _recognizedWords = result.recognizedWords;
      _statusText = '"$_recognizedWords"' ;
    });
    if (result.finalResult) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      _sendMessage();
    }
  }

  Future<void> _sendMessage() async {
    if (_speechToText.isListening) {
      await _stopListening();
    }

    final text = _recognizedWords;
    if (text.isEmpty) {
      setState(() => _statusText = "Không nhận được giọng nói. Thử lại!");
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _statusText = "${widget.characterName} đang suy nghĩ...";
    });

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": text,
          "character_id": widget.characterId,
        }),
      ).timeout(const Duration(minutes: 2));

      if (response.statusCode == 200 && response.headers['content-type']?.contains('audio/mpeg') == true) {
        setState(() {
          _statusText = "${widget.characterName} đang trả lời...";
        });
        final audioSource = MyCustomAudioSource(response.bodyBytes);
        await _audioPlayer.setAudioSource(audioSource);
        _audioPlayer.play();
      } else {
        String errorMessage;
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorJson = jsonDecode(errorBody);
          errorMessage = errorJson['detail'] ?? "Unknown server error.";
        } catch (e) {
          errorMessage = "Error ${response.statusCode}: ${response.reasonPhrase}";
        }
         if (!mounted) return;
        setState(() => _statusText = "Lỗi: $errorMessage");
      }
    } catch (e) {
      if (!mounted) return;
       setState(() => _statusText = "Lỗi mạng: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.characterName}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 2),
            CircleAvatar(
              radius: 100,
              backgroundImage: NetworkImage(widget.characterImageUrl),
              backgroundColor: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(flex: 3),
            GestureDetector(
              onTap: (_isLoading || !_speechEnabled)
                  ? null
                  : (_isListening ? _stopListening : _startListening),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _isListening ? Colors.red.shade700 : Theme.of(context).primaryColor,
                child: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
