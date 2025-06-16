import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _sortBySongName = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favSongs = ref.watch(getFavSongsProvider);
    final currentUser = ref.watch(currentUserNotifierProvider);

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: Pallete.backgroundColor,
        title: const Text(
          "My Library",
          style: TextStyle(
            color: Pallete.whiteColor,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              size: 35,
              _sortBySongName ? Icons.sort_by_alpha : Icons.sort,
              color: Pallete.whiteColor,
            ),
            onPressed: () {
              setState(() {
                _sortBySongName = !_sortBySongName;
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: Pallete.whiteColor,
              size: 35,
            ),
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
            },
          )
        ],
      ),
      body: favSongs.when(
        data: (data) {
          final filteredSongs = (data ?? []).where((song) {
            return song.song_name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();

          if (_sortBySongName) {
            filteredSongs.sort((a, b) => a.song_name.compareTo(b.song_name));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Pallete.backgroundColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                        });

                        if (query.isNotEmpty && filteredSongs.isEmpty) {
                          Future.delayed(Duration.zero, () {
                            showSnackBar(
                                context, '🔍 No matching songs found!');
                          });
                        }
                      },
                      style: const TextStyle(color: Pallete.whiteColor),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Pallete.subtitleText,
                        ),
                        hintText: 'Search for songs...',
                        hintStyle: const TextStyle(color: Pallete.subtitleText),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2.0), 
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (filteredSongs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No Songs Available!',
                        style: const TextStyle(
                          color: Pallete.subtitleText,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];

                      return ListTile(
                        onTap: () {
                          ref
                              .read(currentSongNotifierProvider.notifier)
                              .updateSong(song);
                        },
                        leading: CircleAvatar(
                          backgroundImage: song.thumbnail_url.isNotEmpty
                              ? NetworkImage(song.thumbnail_url)
                              : const NetworkImage(
                                  'https://via.placeholder.com/150'),
                          radius: 35,
                          backgroundColor: Pallete.backgroundColor,
                        ),
                        title: Text(
                          song.song_name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Pallete.whiteColor,
                          ),
                        ),
                        subtitle: Text(
                          song.artist,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Pallete.subtitleText,
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        error: (error, st) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "❌ Error: ${error.toString()}",
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        loading: () => const Loader(),
      ),
    );
  }
}
