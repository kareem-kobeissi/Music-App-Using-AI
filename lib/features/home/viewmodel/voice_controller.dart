import 'dart:convert';
import 'package:client/core/constants/server_constant.dart';
import 'package:client/features/auth/view/pages/playlist_page.dart';
import 'package:client/features/home/viewmodel/singleton.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio_background/just_audio_background.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

class VoiceController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer player = AudioPlayerSingleton.instance;

  bool isListening = false;

  Future<void> startListening(BuildContext context) async {
    if (_speech.isListening) {
      await _speech.stop();
    }

    bool available = await _speech.initialize();
    if (available) {
      isListening = true;
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            String command = result.recognizedWords;
            print("🎤 Recognized: $command");
            sendCommandToBackend(command, context);
          }
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Speech recognition not available")),
      );
    }
  }

  // Stop listening to voice commands
  Future<void> stopListening() async {
    await _speech.stop();
    isListening = false;
  }

  // Send the recognized command to the backend and handle the response
  Future<void> sendCommandToBackend(
      String command, BuildContext context) async {
    try {
      var res = await http.post(
        Uri.parse("${ServerConstant.serverURL}/auth/voice-command"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"command": command}),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);

        // Handle "create playlist" command
        if (data["action"] == "create_playlist") {
          // Display success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ Playlist '${data['playlist_name']}' created!"),
            ),
          );
        }

        // Handle play command
        else if (data["action"] == "play") {
          await player.setAudioSource(
            AudioSource.uri(
              Uri.parse(data["song_url"]),
              tag: MediaItem(
                id: data["song_url"],
                album: data["artist"] ?? "Unknown",
                title: data["song_name"] ?? "Unknown",
                artUri: Uri.parse(data["thumbnail_url"] ?? ""),
              ),
            ),
          );
          await player.play();

          // Shuffle or play message
          final isShuffle = command.toLowerCase().contains("shuffle");
          final playMsg = isShuffle
              ? "🔀 Shuffle playing: ${data['song_name']}"
              : "🎵 Now playing: ${data['song_name']}";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(playMsg)),
          );
        }

        // Handle pause command
        else if (data["action"] == "pause") {
          await player.pause();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⏸️ Music paused")),
          );
        }

        // Handle continue command
        else if (data["action"] == "continue") {
          await player.play();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("▶️ Music resumed")),
          );
        }

        // Handle navigation to Playlist page command
        else if (data["action"] == "navigate_to_playlist") {
          // Navigate to Playlist Page without using named routes
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const PlaylistPage()), // Assuming PlaylistPage is the page you want to navigate to
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("🚀 Navigating to Playlist page")),
          );
        }

        // Handle unknown or unmatched command
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ No matching song found")),
          );
        }
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }
}
