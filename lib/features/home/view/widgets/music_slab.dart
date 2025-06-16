import 'dart:convert';
import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/view/widgets/music_player.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class MusicSlab extends ConsumerWidget {
  const MusicSlab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);
    final userFavorites = ref.watch(
      currentUserNotifierProvider.select((data) => data!.favorites),
    );

    if (currentSong == null) return const SizedBox();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MusicPlayer(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween =
                  Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
                CurveTween(curve: Curves.easeIn),
              );
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            },
          ),
        );
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 70,
            width: MediaQuery.of(context).size.width - 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  hexToColor(currentSong.hex_code).withOpacity(0.5),
                  Colors.black.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Hero(
                  tag: 'music-image',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(currentSong.thumbnail_url),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSong.song_name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Pallete.whiteColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        currentSong.artist,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Pallete.subtitleText,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showAddToPlaylistDialog(
                          context, ref, currentSong.id),
                      icon: const Icon(CupertinoIcons.folder_badge_plus,
                          color: Pallete.whiteColor, size: 22),
                    ),
                    IconButton(
                      onPressed: () =>
                          _simulateDownload(context, currentSong.song_name),
                      icon: const Icon(CupertinoIcons.arrow_down_to_line,
                          color: Pallete.whiteColor, size: 22),
                    ),
                    IconButton(
                      onPressed: () async {
                        await ref
                            .read(homeViewmodelProvider.notifier)
                            .favSong(songId: currentSong.id);
                        final isFav = userFavorites
                            .any((fav) => fav.song_id == currentSong.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isFav
                                ? 'Song removed from your library!'
                                : 'Song added to your library!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(
                        userFavorites
                                .any((fav) => fav.song_id == currentSong.id)
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: Pallete.whiteColor,
                        size: 22,
                      ),
                    ),
                    IconButton(
                      onPressed: songNotifier.playPause,
                      icon: Icon(
                        songNotifier.isPlaying
                            ? CupertinoIcons.pause_fill
                            : CupertinoIcons.play_fill,
                        color: Pallete.whiteColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(
      BuildContext context, WidgetRef ref, String songId) async {
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url = Uri.parse('${ServerConstant.serverURL}/auth/get-playlists');
    List<Map<String, dynamic>> playlists = [];

    try {
      final response = await http.get(url, headers: {
        'x-auth-token': token!,
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          playlists = List<Map<String, dynamic>>.from(jsonData);
          print("📂 Playlists Received: $playlists");
        }
      } else {
        throw Exception("Failed to fetch playlists.");
      }
    } catch (e) {
      print("❌ Error loading playlists: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to load playlists")),
      );
      return;
    }

    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ No playlists available!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Playlist"),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              final playlistId = playlist["id"];

              print("📝 Playlist Data: $playlist");

              if (playlistId == null || playlistId.toString().isEmpty) {
                print("⚠️ Skipping invalid playlist (No ID): $playlist");
                return const SizedBox.shrink();
              }

              return ListTile(
                title: Text(playlist["name"]),
                onTap: () async {
                  print("📥 Adding song: $songId to playlist: $playlistId");
                  final addUrl = Uri.parse(
                      '${ServerConstant.serverURL}/auth/add-song-to-playlist');

                  try {
                    final addResponse = await http.post(
                      addUrl,
                      headers: {
                        'x-auth-token': token,
                        'Content-Type': 'application/json',
                      },
                      body: json.encode({
                        "playlist_id": playlistId.toString(),
                        "song_id": songId.toString(),
                      }),
                    );

                    print("🛠 API Response: ${addResponse.body}");

                    Navigator.pop(context);

                    if (addResponse.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("✅ Song added to '${playlist["name"]}'")),
                      );
                    } else {
                      print(
                          "❌ API Error [${addResponse.statusCode}]: ${addResponse.body}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("❌ Failed: ${addResponse.body}")),
                      );
                    }
                  } catch (e) {
                    print("❌ Exception: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Song is already found in playlist!")),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _simulateDownload(BuildContext context, String songName) {
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Music downloaded successfully: "$songName"'),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }
}
