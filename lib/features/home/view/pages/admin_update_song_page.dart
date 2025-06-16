import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminSongsPage extends ConsumerStatefulWidget {
  const AdminSongsPage({super.key});

  @override
  _AdminSongsPageState createState() => _AdminSongsPageState();
}

class _AdminSongsPageState extends ConsumerState<AdminSongsPage> {
  List<Map<String, dynamic>> songs = [];
  bool isLoading = true;
  String? errorMessage;

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

  Future<void> updateSongDetails(
      String songId, String newSongName, String newArtistName) async {
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url =
        Uri.parse('${ServerConstant.serverURL}/auth/update-song/$songId');

    try {
      final response = await http.put(
        url,
        headers: {
          'x-auth-token': token!,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "song_name": newSongName,
          "artist": newArtistName,
          "type": "song_update"
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          final songIndex = songs.indexWhere((song) => song["id"] == songId);
          if (songIndex != -1) {
            songs[songIndex]["song_name"] = newSongName;
            songs[songIndex]["artist"] = newArtistName;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Song details updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("❌ Failed to update song details: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  Future<void> deleteSong(String songId) async {
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url =
        Uri.parse('${ServerConstant.serverURL}/auth/delete-song/$songId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'x-auth-token': token!,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          songs.removeWhere((song) => song["id"] == songId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Song deleted successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to delete song: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  void _showEditSongDialog(
      String songId, String currentSongName, String currentArtistName) {
    TextEditingController songNameController =
        TextEditingController(text: currentSongName);
    TextEditingController artistNameController =
        TextEditingController(text: currentArtistName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Song Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: songNameController,
              decoration: const InputDecoration(labelText: "New Song Name"),
            ),
            TextField(
              controller: artistNameController,
              decoration: const InputDecoration(labelText: "New Artist Name"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (songNameController.text.trim().isNotEmpty &&
                  artistNameController.text.trim().isNotEmpty) {
                updateSongDetails(songId, songNameController.text.trim(),
                    artistNameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Update", style: TextStyle(color: Colors.blue)),
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Pallete.whiteColor,
            size: 35,
          ),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        title: const Text(
          "Manage Songs",
          style: TextStyle(
            color: Pallete.whiteColor,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Pallete.transparentColor,
      ),
      body: RefreshIndicator(
        onRefresh: fetchSongs,
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Text(errorMessage!,
                              style: const TextStyle(color: Colors.red)))
                      : songs.isEmpty
                          ? const Center(
                              child: Text(
                                "No songs available!",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : ListView.builder(
                              itemCount: songs.length,
                              itemBuilder: (context, index) {
                                final song = songs[index];

                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      song["thumbnail_url"] ??
                                          'https://via.placeholder.com/150',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    song["song_name"] ?? 'Unknown Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Pallete.whiteColor,
                                    ),
                                  ),
                                  subtitle:
                                      Text(song["artist"] ?? 'Unknown Artist'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          _showEditSongDialog(
                                              song["id"],
                                              song["song_name"],
                                              song["artist"]);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          _showDeleteConfirmation(song["id"]);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String songId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Song"),
        content: const Text("Are you sure you want to delete this song?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteSong(songId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
