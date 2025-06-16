import 'dart:convert';

import 'package:client/core/constants/server_constant.dart' show ServerConstant;
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class SongsPage extends ConsumerStatefulWidget {
  const SongsPage({super.key});

  @override
  _SongsPageState createState() => _SongsPageState();
}

class _SongsPageState extends ConsumerState<SongsPage> {
  late AudioPlayer _audioPlayer;

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    Future.delayed(Duration.zero, () {
      _showInfoDialog();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _sendSongRequest(String songName) async {
    final String? token =
        ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url = Uri.parse('${ServerConstant.serverURL}/auth/request-song');

    try {
      final response = await http.post(
        url,
        headers: {
          'x-auth-token': token!,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'song_name': songName,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Song request submitted successfully to the admin!')),
        );
      } else {
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseBody['detail'] ?? 'Failed to request song.')),
        );
      }
    } catch (e) {
      print("Error sending song request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting song request.')),
      );
    }
  }

  void _showRequestSongDialog(BuildContext context) {
    TextEditingController songController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Pallete.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "You have a song in mind?\nNow and exclusive in this app you can request it to the admin!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: songController,
                style: const TextStyle(color: Pallete.whiteColor),
                cursorColor: Pallete.whiteColor,
                decoration: const InputDecoration(
                  hintText: 'Enter the song name...',
                  hintStyle: TextStyle(color: Pallete.subtitleText),
                  filled: true,
                  fillColor: Pallete.backgroundColor,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              AuthGradientButton(
                buttonText: "Send Request",
                onTap: () {
                  if (songController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a song name.')),
                    );
                    return;
                  }
                  _sendSongRequest(songController.text);
                  Navigator.pop(context);
                },
                icon: CupertinoIcons.plus,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentlyPlayedSongs = ref
        .watch(homeViewmodelProvider.notifier)
        .getRecentlyPlayedSongs()
        .where((song) =>
            song.song_name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    final currentSong = ref.watch(currentSongNotifierProvider);

    return SingleChildScrollView(
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: currentSong == null
                ? null
                : BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        hexToColor(currentSong.hex_code).withOpacity(0.5),
                        hexToColor(currentSong.hex_code).withOpacity(0.5),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16, bottom: 10),
                    child: SizedBox(
                      height: 280,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: recentlyPlayedSongs.length,
                        itemBuilder: (context, index) {
                          final song = recentlyPlayedSongs[index];
                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(currentSongNotifierProvider.notifier)
                                  .updateSong(song);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: currentSong != null
                                    ? LinearGradient(colors: [
                                        hexToColor(currentSong!.hex_code)
                                            .withOpacity(0.9),
                                        Pallete.backgroundColor,
                                      ])
                                    : null,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.only(right: 20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(song.thumbnail_url),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      song.song_name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Pallete.whiteColor,
                                        fontWeight: FontWeight.w700,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Latest Today',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            color: Pallete.whiteColor,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                color: Pallete.whiteColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  _showRequestSongDialog(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.add,
                                      color: Pallete.whiteColor,
                                      size: 25,
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Request Song',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Pallete.whiteColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ref.watch(getAllSongsProvider).when(
                        data: (songs) {
                          return SizedBox(
                            height: 295,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: songs.length,
                              itemBuilder: (context, index) {
                                final song = songs[index];
                                return GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(currentSongNotifierProvider
                                            .notifier)
                                        .updateSong(song);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 180,
                                          height: 180,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  song.thumbnail_url),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(7),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        SizedBox(
                                          width: 180,
                                          child: Text(
                                            song.song_name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              overflow: TextOverflow.ellipsis,
                                              color: Pallete.whiteColor,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 180,
                                          child: Text(
                                            song.artist,
                                            style: const TextStyle(
                                              color: Pallete.subtitleText,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        error: (error, st) {
                          return Center(child: Text(error.toString()));
                        },
                        loading: () => const Loader(),
                      ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 45,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recently Played",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Pallete.whiteColor,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  decoration: BoxDecoration(
                    color: Pallete.whiteColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                    style: const TextStyle(
                        color: Pallete.whiteColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Pallete.whiteColor,
                          fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      prefixIcon: Icon(Icons.search, color: Pallete.whiteColor),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                  searchController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            "Tap on any song image to start playing the music. Enjoy! 🎶"),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Got it!',
          onPressed: () {},
        ),
      ),
    );
  }
}
