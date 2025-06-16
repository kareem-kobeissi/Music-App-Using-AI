import 'dart:convert';
import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/auth/view/pages/playlist_songs_page.dart';
import 'package:client/features/auth/view/pages/subscription_page.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class PlaylistPage extends ConsumerStatefulWidget {
  const PlaylistPage({super.key});

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends ConsumerState<PlaylistPage> {
  List<Map<String, dynamic>> playlists = [];
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();

    if (token == null) {
      setState(() {
        errorMessage = "Error: No token found!";
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('${ServerConstant.serverURL}/auth/get-playlists');

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
        setState(() {
          playlists = List<Map<String, dynamic>>.from(jsonResponse);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch playlists: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> createPlaylist(String playlistName) async {
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url = Uri.parse('${ServerConstant.serverURL}/auth/create-playlist');

    try {
      final response = await http.post(
        url,
        headers: {
          'x-auth-token': token!,
          'Content-Type': 'application/json',
        },
        body: json.encode({"name": playlistName}),
      );

      if (response.statusCode == 200) {
        fetchPlaylists();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Playlist created successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ Failed to create playlist: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  Future<void> editPlaylist(String playlistId, String newName) async {
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url = Uri.parse(
        '${ServerConstant.serverURL}/auth/update-playlist/$playlistId');

    try {
      final response = await http.put(
        url,
        headers: {
          'x-auth-token': token!,
          'Content-Type': 'application/json',
        },
        body: json.encode({"name": newName}),
      );

      if (response.statusCode == 200) {
        fetchPlaylists();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Playlist updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ Failed to update playlist: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url = Uri.parse(
        '${ServerConstant.serverURL}/auth/delete-playlist/$playlistId');

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
          playlists.removeWhere((playlist) => playlist["id"] == playlistId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Playlist deleted successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ Failed to delete playlist: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  void _showAddPlaylistDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Pallete.backgroundColor.withOpacity(0.95),
        titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        actionsPadding: const EdgeInsets.only(bottom: 12, right: 16),
        title: const Text(
          "🎵 Create New Playlist",
          style: TextStyle(
            color: Pallete.whiteColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Give your playlist a cool name:",
              style: TextStyle(
                fontSize: 14,
                color: Pallete.subtitleText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Pallete.whiteColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: Pallete.whiteColor.withOpacity(0.1),
                hintText: "Playlist Name",
                hintStyle: const TextStyle(color: Pallete.subtitleText),
                prefixIcon:
                    const Icon(Icons.music_note, color: Pallete.whiteColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                createPlaylist(name);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Create"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPlaylistDialog(String playlistId, String currentName) {
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Pallete.backgroundColor.withOpacity(0.95),
        titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        actionsPadding: const EdgeInsets.only(bottom: 12, right: 16),
        title: const Text(
          "✏️ Rename Playlist",
          style: TextStyle(
            color: Pallete.whiteColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Give your playlist a fresh name:",
              style: TextStyle(
                fontSize: 14,
                color: Pallete.subtitleText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Pallete.whiteColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: Pallete.whiteColor.withOpacity(0.1),
                hintText: "New Playlist Name",
                hintStyle: const TextStyle(color: Pallete.subtitleText),
                prefixIcon: const Icon(Icons.edit, color: Pallete.whiteColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                editPlaylist(playlistId, newName);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.check),
            label: const Text("Save"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: Pallete.backgroundColor,
        title: const Text(
          "My Playlists",
          style: TextStyle(
              color: Pallete.whiteColor,
              fontSize: 23,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Pallete.whiteColor, size: 35),
            onPressed: _showAddPlaylistDialog,
          ),
          IconButton(
            icon: const Icon(
              Icons.subscriptions_outlined,
              color: Pallete.whiteColor,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubscriptionPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchPlaylists,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query.toLowerCase();
                  });
                },
                style: const TextStyle(color: Pallete.whiteColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Pallete.whiteColor.withOpacity(0.1),
                  hintText: "Search for playlists...",
                  hintStyle: const TextStyle(color: Pallete.subtitleText),
                  prefixIcon:
                      const Icon(Icons.search, color: Pallete.subtitleText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : playlists.isEmpty
                          ? const Center(
                              child: Text(
                                "No playlists available!",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 18),
                              ),
                            )
                          : ListView.builder(
                              itemCount: playlists
                                  .where((playlist) => playlist["name"]
                                      .toLowerCase()
                                      .contains(_searchQuery))
                                  .length,
                              itemBuilder: (context, index) {
                                final filteredPlaylists = playlists
                                    .where((playlist) => playlist["name"]
                                        .toLowerCase()
                                        .contains(_searchQuery))
                                    .toList();
                                final playlist = filteredPlaylists[index];

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Pallete.whiteColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.library_music,
                                          color: Colors.blueAccent, size: 32),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            final token = ref
                                                .read(homeViewmodelProvider
                                                    .notifier)
                                                .getUserToken();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    PlaylistSongsPage(
                                                  playlistId: playlist["id"],
                                                  playlistName:
                                                      playlist["name"],
                                                  token: token!,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                playlist["name"],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Pallete.whiteColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                "Tap to view songs",
                                                style: TextStyle(
                                                    color: Pallete.subtitleText,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.green, size: 35),
                                        onPressed: () =>
                                            _showEditPlaylistDialog(
                                                playlist["id"],
                                                playlist["name"]),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_forever,
                                            color: Colors.redAccent, size: 35),
                                        onPressed: () =>
                                            _showDeleteConfirmationDialog(
                                                playlist["id"],
                                                playlist["name"]),
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

  void _showDeleteConfirmationDialog(String playlistId, String playlistName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Pallete.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "🗑️ Delete Playlist",
          style:
              TextStyle(color: Pallete.whiteColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete \"$playlistName\"?\nThis cannot be undone.",
          style: const TextStyle(color: Pallete.subtitleText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              deletePlaylist(playlistId);
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
}
