import 'dart:convert';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/home/viewmodel/voice_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:client/core/constants/server_constant.dart'; 
import 'package:client/features/home/viewmodel/home_viewmodel.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceAssistantPage extends ConsumerStatefulWidget {
  const VoiceAssistantPage({super.key});

  @override
  _VoiceAssistantPageState createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends ConsumerState<VoiceAssistantPage> {
  List<Map<String, dynamic>> songs = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }


  Future<void> fetchSongs() async {
    print("📡 Fetching songs from API...");
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();

    if (token == null) {
      setState(() {
        errorMessage = "Error: No token found!";
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('${ServerConstant.serverURL}/auth/get-songs');

    try {
      final response = await http.get(
        url,
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse is List) {
          setState(() {
            songs = jsonResponse.map((song) {
              return {
                "id": song["id"] ?? 'Unknown ID',
                "song_name": song["song_name"] ?? 'Unknown Name',
                "artist": song["artist"] ?? 'Unknown Artist',
                "thumbnail_url":
                    song["thumbnail_url"] ?? 'https://via.placeholder.com/150',
              };
            }).toList();
            isLoading = false;
          });

          print("✅ Successfully loaded ${songs.length} songs.");
        } else {
          throw "Unexpected response format.";
        }
      } else {
        print("❌ API Error: ${response.body}");
        setState(() {
          errorMessage = "Failed to fetch songs: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  void _showVoiceInstructionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 12,
          title: Row(
            children: [
              Icon(
                Icons.mic_none,
                color: Colors.blueAccent,
                size: 32,
              ),
              const SizedBox(width: 15),
              Text(
                'Voice Assistant ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInstructionRow(
                  Icons.volume_up,
                  'Speak clearly and loudly',
                  Colors.green,
                ),
                _buildInstructionRow(
                  Icons.access_time,
                  'Talk slowly for better understanding',
                  Colors.orange,
                ),
                _buildInstructionRow(
                  Icons.music_note,
                  'Say the song name to search',
                  Colors.purple,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: const Text(
                'Got it!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Pallete.backgroundColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstructionRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 5.0), 
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text, 
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true, 
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Voice Assistant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.mic,
              color: Pallete.whiteColor,
              size: 35,
            ),
            onPressed:
                _showVoiceInstructionsDialog, 
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'AI Voice Assistant Functionality Goes Here!',
                      style: TextStyle(
                          fontSize: 20, color: Pallete.inactiveSeekColor),
                    ),
                    const SizedBox(height: 20),
                    const VoiceControlWidget(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return ListTile(
                            leading: Image.network(song["thumbnail_url"]!),
                            title: Text(
                              song["song_name"]!,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(song["artist"]!),
                            onTap: () {
                              print('Song selected: ${song["song_name"]}');
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
