import 'dart:convert';
import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class PlaylistSongsPage extends ConsumerStatefulWidget {
  final String playlistId;
  final String playlistName;
  final String token;

  const PlaylistSongsPage({
    super.key,
    required this.playlistId,
    required this.playlistName,
    required this.token,
  });

  @override
  ConsumerState<PlaylistSongsPage> createState() => _PlaylistSongsPageState();
}

class _PlaylistSongsPageState extends ConsumerState<PlaylistSongsPage> {
  List<dynamic> songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    final url = Uri.parse(
      '${ServerConstant.serverURL}/auth/playlist-songs/${widget.playlistId}',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'x-auth-token': widget.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          songs = data["songs"];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("❌ Failed to fetch songs: ${response.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error: $e");
    }
  }

  void removeSong(String songId) async {
    final url = Uri.parse(
      '${ServerConstant.serverURL}/auth/remove-from-playlist/${widget.playlistId}/$songId',
    );

    try {
      final response = await http.delete(
        url,
        headers: {
          'x-auth-token': widget.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Song removed from playlist")),
        );
        fetchSongs();
      } else {
        print("❌ Failed to remove song: ${response.body}");
      }
    } catch (e) {
      print("❌ Error removing song: $e");
    }
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String songId, String songName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Pallete.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "🗑️ Delete Song",
          style:
              TextStyle(color: Pallete.whiteColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete \"$songName\"?\nThis cannot be undone.",
          style: const TextStyle(color: Pallete.subtitleText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              removeSong(songId);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(currentSongNotifierProvider);

    final userFavorites = ref.watch(
      currentUserNotifierProvider.select((data) => data!.favorites),
    );

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              final currentSong = ref.watch(currentSongNotifierProvider);
              final String playlistDetails = 'Check out this playlist!!';
              Share.share(playlistDetails);
            },
          ),
        ],
        backgroundColor: Pallete.transparentColor,
        title: Text(
          widget.playlistName,
          style: const TextStyle(
            color: Pallete.whiteColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : songs.isEmpty
              ? const Center(
                  child: Text(
                    "🎶 No songs in this playlist.",
                    style: TextStyle(color: Pallete.whiteColor, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final songId = song["id"] ?? song["song_id"];
                    final isFav =
                        userFavorites.any((fav) => fav.song_id == songId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Pallete.whiteColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              song["thumbnail_url"] ?? '',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey,
                                child: const Icon(Icons.music_note,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song["song_name"] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Pallete.whiteColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  song["artist"] ?? 'Unknown Artist',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Pallete.subtitleText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  size: 35,
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav
                                      ? Colors.redAccent
                                      : Pallete.whiteColor,
                                ),
                                onPressed: () async {
                                  await ref
                                      .read(homeViewmodelProvider.notifier)
                                      .favSong(songId: songId);

                                  final nowFav = ref
                                      .read(currentUserNotifierProvider)!
                                      .favorites
                                      .any((fav) => fav.song_id == songId);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(nowFav
                                          ? 'Song added to your library!'
                                          : 'Song removed from your library!'),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete_outline, size: 35),
                                color: Colors.redAccent,
                                onPressed: () {
                                  final songName =
                                      song["song_name"] ?? 'Unknown';
                                  _showDeleteConfirmationDialog(
                                      context, songId, songName);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
