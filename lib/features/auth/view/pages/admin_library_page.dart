import 'package:client/core/theme/app_pallette.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminLibraryPage extends ConsumerStatefulWidget {
  const AdminLibraryPage({super.key});

  @override
  _AdminLibraryPageState createState() => _AdminLibraryPageState();
}

class _AdminLibraryPageState extends ConsumerState<AdminLibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSongs = ref.watch(getAllSongsProvider);

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: Pallete.backgroundColor,
        title: const Text(
          "Admin Songs",
          style: TextStyle(
            color: Pallete.whiteColor,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: allSongs.when(
        data: (songs) {
          final filteredSongs = songs
              .where((song) =>
                  song.song_name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                  style: const TextStyle(color: Pallete.whiteColor),
                  decoration: InputDecoration(
                    hintText: 'Search Songs...',
                    hintStyle: TextStyle(color: Pallete.subtitleText),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Pallete.backgroundColor.withOpacity(0.8),
                  ),
                ),
              ),

              Expanded(
                child: filteredSongs.isEmpty
                    ? const Center(
                        child: Text(
                          'No Songs Available!',
                          style: TextStyle(
                              color: Pallete.subtitleText, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = filteredSongs[index];

                          return ListTile(
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
              ),
            ],
          );
        },
        error: (error, st) => Center(
          child: Text(
            "❌ Error: ${error.toString()}",
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
        loading: () => const Loader(),
      ),
    );
  }
}
