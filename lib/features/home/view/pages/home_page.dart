import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/auth/view/pages/library_page.dart';
import 'package:client/features/auth/view/pages/settings_page.dart';
import 'package:client/features/auth/view/pages/songs_page.dart';
import 'package:client/features/auth/view/pages/playlist_page.dart';
import 'package:client/features/auth/view/pages/voice_assistance_page.dart';
import 'package:client/features/home/view/widgets/music_slab.dart';
import 'package:client/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const SongsPage(),
    const LibraryPage(),
    const PlaylistPage(),
    const SettingsPage(),
    const VoiceAssistantPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(currentSongNotifierProvider);

    final backgroundColor =
        currentSong != null && currentSong.hex_code.isNotEmpty
            ? hexToColor(currentSong.hex_code).withOpacity(0.3)
            : Pallete.backgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          pages[selectedIndex],
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MusicSlab(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          if (value == 4) {
            // Show dialog before navigating to Assistant
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      20), // Rounded corners for modern look
                ),
                backgroundColor: Colors.white, // Clean white background
                elevation: 10, // Adds subtle shadow effect
                title: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Pallete
                          .primaryColor, // Icon color matching primary color
                      size: 32, // Icon size adjusted for better balance
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Important Notice',
                        overflow:
                            TextOverflow.ellipsis, // Prevent text overflow
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Slightly smaller font for the title
                          color: Pallete.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'To ensure the best experience, tap the song image to play or use the AI Voice Assistant to control the app.',
                    style: TextStyle(
                      fontSize: 14, // Smaller content font for balance
                      color: Colors.black87, // Soft black color for readability
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      setState(() {
                        selectedIndex = value; // Proceed to the Assistant page
                      });
                    },
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      backgroundColor: Pallete.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Got it',
                      style: TextStyle(
                        color: Pallete.backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            setState(() {
              selectedIndex =
                  value; // Navigate normally if it's not the Assistant tab
            });
          }
        },
        backgroundColor: Pallete.backgroundColor,
        selectedItemColor: Pallete.backgroundColor,
        unselectedItemColor: Pallete.inactiveBottomBarItemColor,
        items: [
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.2).animate(animation),
                  child: child,
                );
              },
              child: Image.asset(
                selectedIndex == 0
                    ? 'assets/images/home_filled.png'
                    : 'assets/images/home_unfilled.png',
                key: ValueKey<int>(selectedIndex),
                color: selectedIndex == 0
                    ? Pallete.backgroundColor
                    : Pallete.inactiveBottomBarItemColor,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.2).animate(animation),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/library.png',
                key: ValueKey<int>(selectedIndex),
                color: selectedIndex == 1
                    ? Pallete.backgroundColor
                    : Pallete.inactiveBottomBarItemColor,
              ),
            ),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.2).animate(animation),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/playlist.png',
                key: ValueKey<int>(selectedIndex),
                color: selectedIndex == 2
                    ? Pallete.backgroundColor
                    : Pallete.inactiveBottomBarItemColor,
              ),
            ),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.2).animate(animation),
                  child: child,
                );
              },
              child: Icon(
                selectedIndex == 3 ? Icons.settings : Icons.settings_outlined,
                key: ValueKey<int>(selectedIndex),
                color: selectedIndex == 3
                    ? Pallete.backgroundColor
                    : Pallete.inactiveBottomBarItemColor,
              ),
            ),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.2).animate(animation),
                  child: child,
                );
              },
              child: Icon(
                Icons.mic,
                key: ValueKey<int>(selectedIndex),
                color: selectedIndex == 4
                    ? Pallete.backgroundColor
                    : Pallete.inactiveBottomBarItemColor,
              ),
            ),
            label: 'Assistant',
          ),
        ],
      ),
    );
  }
}
