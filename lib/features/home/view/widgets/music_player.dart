import 'dart:convert';
import 'dart:math';

import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/providers/sleep_timer_notifier.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/providers/sleep_time_picker.dart';
import 'package:client/features/auth/view/pages/playlist_page.dart';
import 'package:client/features/auth/view/pages/subscription_page.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/view/widgets/artist_details_page.dart';
import 'package:client/features/home/view/widgets/artist_model.dart';
import 'package:client/features/home/view/widgets/artist_data.dart';
import 'package:client/features/home/view/widgets/balance.dart';
import 'package:client/features/home/view/widgets/bass_notifier.dart';
import 'package:client/features/home/view/widgets/lyrics_page.dart';
import 'package:client/features/home/view/widgets/song_service.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({
    super.key,
  });

  Future<void> fetchRecommendedSongs(
      String genre, BuildContext context, WidgetRef ref) async {
    print("📡 Fetching recommended songs for genre: $genre...");
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No token found!")),
      );
      return;
    }

    final url = Uri.parse(
        '${ServerConstant.serverURL}/auth/recommend-songs?genre=$genre');

    try {
      final response = await http.get(
        url,
        headers: {
          'x-auth-token': token!,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('recommended_songs') &&
            jsonResponse['recommended_songs'] is List) {
          final recommendedSongs =
              jsonResponse['recommended_songs'].map((song) {
            return {
              "id": song["id"] ?? 'Unknown ID',
              "song_name": song["song_name"] ?? 'Unknown Name',
              "artist": song["artist"] ?? 'Unknown Artist',
              "thumbnail_url":
                  song["thumbnail_url"] ?? 'https://via.placeholder.com/150',
              "song_url":
                  song["song_url"] ?? '', // Ensure song_url is also included
            };
          }).toList();

          print(
              "✅ Successfully loaded ${recommendedSongs.length} recommended songs.");
          showModalBottomSheet(
            context: context,
            backgroundColor: Pallete.backgroundColor,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Recommended Songs - $genre', // This will display the genre beside the text
                      style: TextStyle(
                        color: Pallete.whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: recommendedSongs.length,
                        itemBuilder: (context, index) {
                          final song = recommendedSongs[index];
                          return ListTile(
                            title: Text(
                              song["song_name"],
                              style: const TextStyle(color: Pallete.whiteColor),
                            ),
                            subtitle: Text(
                              song["artist"],
                              style: const TextStyle(color: Pallete.whiteColor),
                            ),
                            onTap: () {},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          throw "Unexpected response format or missing 'recommended_songs'.";
        }
      } else {
        print("❌ API Error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Failed to fetch recommended songs: ${response.body}")),
        );
      }
    } catch (e) {
      print("❌ Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);
    final userFavorites = ref
        .watch(currentUserNotifierProvider.select((data) => data!.favorites));
    bool isMuted = songNotifier.singletonAudioPlayer!.volume == 0.0;

    final List<double> playbackSpeeds = [0.5, 1.0, 1.5, 2.0];
    double selectedSpeed = songNotifier.audioPlayer!.speed;

    final gradientColors = [
      hexToColor(currentSong!.hex_code).withOpacity(0.5),
      hexToColor(currentSong.hex_code).withOpacity(0.5),
      Colors.transparent,
    ];

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! > 10) {
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Pallete.transparentColor,
          appBar: AppBar(
            backgroundColor: Pallete.transparentColor,
            leading: Transform.translate(
              offset: const Offset(-15, 0),
              child: InkWell(
                highlightColor: Pallete.transparentColor,
                focusColor: Pallete.transparentColor,
                splashColor: Pallete.transparentColor,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/pull-down-arrow.png',
                    color: Pallete.whiteColor,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.headset,
                  color: Pallete.whiteColor,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Pallete.backgroundColor,
                    builder: (context) {
                      return Consumer(
                        builder: (context, ref, _) {
                          bool is3DAudioEnabled =
                              ref.watch(surroundSoundNotifierProvider);

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Adjust Surround Sound (3D Audio)',
                                  style: TextStyle(
                                    color: Pallete.whiteColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SwitchListTile(
                                  title: const Text(
                                    'Enable 3D Audio',
                                    style: TextStyle(
                                      color: Pallete.whiteColor,
                                    ),
                                  ),
                                  value: is3DAudioEnabled,
                                  onChanged: (value) {
                                    ref
                                        .read(surroundSoundNotifierProvider
                                            .notifier)
                                        .setSurroundSound(value);

                                    if (value) {
                                      songNotifier.audioPlayer!
                                          .set3DAudioEnabled(true);
                                    } else {
                                      songNotifier.audioPlayer!
                                          .set3DAudioEnabled(false);
                                    }
                                  },
                                  activeColor: Pallete.whiteColor,
                                  inactiveThumbColor: Pallete.subtitleText,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Note: This feature works best with headphones for a true 3D experience.',
                                  style: TextStyle(
                                    color: Pallete.whiteColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.share,
                  color: Pallete.whiteColor,
                ),
                onPressed: () {
                  final String songDetails =
                      'Check out this song: ${currentSong.song_name} by ${currentSong.artist}\nListen now: ${currentSong.song_url}';
                  Share.share(songDetails);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.equalizer,
                  color: Pallete.whiteColor,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Pallete.backgroundColor,
                    builder: (context) {
                      return Consumer(
                        builder: (context, ref, _) {
                          double bassLevel = ref.watch(bassNotifierProvider);

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Adjust Bass Level',
                                  style: TextStyle(
                                    color: Pallete.whiteColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Slider(
                                  min: 0,
                                  max: 1,
                                  value: bassLevel,
                                  onChanged: (value) {
                                    ref
                                        .read(bassNotifierProvider.notifier)
                                        .setBass(value);

                                    songNotifier.audioPlayer!.setVolume(value);
                                  },
                                  activeColor: Pallete.whiteColor,
                                  inactiveColor: Pallete.subtitleText,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  isMuted
                      ? CupertinoIcons.volume_off
                      : CupertinoIcons.volume_up,
                  color: Pallete.whiteColor,
                ),
                onPressed: () {
                  if (isMuted) {
                    songNotifier.audioPlayer!.setVolume(1.0);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('UNMUTED')),
                    );
                  } else {
                    songNotifier.audioPlayer!.setVolume(0.0);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('MUTED')),
                    );
                  }

                  isMuted = !isMuted;
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.timer,
                  color: Pallete.whiteColor,
                ),
                onPressed: () async {
                  final selectedTime = await showModalBottomSheet<Duration>(
                    context: context,
                    builder: (BuildContext context) {
                      return SleepTimerPicker();
                    },
                  );

                  if (selectedTime != null) {
                    ref.read(sleepTimerNotifierProvider.notifier).setSleepTimer(
                        selectedTime, songNotifier.audioPlayer!.stop);
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.schedule,
                  color: Pallete.whiteColor,
                ),
                onPressed: () async {
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (selectedDate != null) {
                    final TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime != null) {
                      DateTime scheduledDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      DateTime now = DateTime.now();

                      if (scheduledDateTime.isBefore(now)) {
                        scheduledDateTime =
                            scheduledDateTime.add(const Duration(days: 1));
                      }

                      final Duration delay = scheduledDateTime.difference(now);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Song scheduled to play at ${scheduledDateTime}',
                          ),
                        ),
                      );

                      Future.delayed(delay, () {
                        songNotifier.playPause();
                      });
                    }
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Hero(
                    tag: 'music-image',
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            currentSong.thumbnail_url,
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.song_name,
                                style: const TextStyle(
                                  color: Pallete.whiteColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.visible,
                              ),
                              Text(
                                currentSong.artist,
                                style: const TextStyle(
                                  color: Pallete.subtitleText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await ref
                                .read(homeViewmodelProvider.notifier)
                                .favSong(
                                  songId: currentSong.id,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  userFavorites
                                          .where((fav) =>
                                              fav.song_id == currentSong.id)
                                          .toList()
                                          .isNotEmpty
                                      ? 'Song removed from your library!'
                                      : 'Song added to your library!',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(
                            userFavorites
                                    .where(
                                        (fav) => fav.song_id == currentSong.id)
                                    .toList()
                                    .isNotEmpty
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: Pallete.whiteColor,
                            size: 35,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final selectedArtist = artists.firstWhere(
                              (artist) => artist.name == currentSong.artist,
                              orElse: () => Artist(
                                name: currentSong.artist,
                                bio: 'No details available for this artist.',
                              ),
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ArtistDetailsPage(artist: selectedArtist),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.person_2_sharp,
                            color: Pallete.whiteColor,
                            size: 35,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.recommend,
                            color: Pallete.whiteColor,
                            size: 35,
                          ),
                          onPressed: () async {
                            final String genre = currentSong.genre;

                            await fetchRecommendedSongs(genre, context, ref);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    StreamBuilder(
                      stream: songNotifier.audioPlayer!.positionStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        }
                        final position = snapshot.data;
                        final duration = songNotifier.audioPlayer!.duration;
                        double sliderValue = 0.0;

                        if (position != null && duration != null) {
                          sliderValue =
                              position.inMilliseconds / duration.inMilliseconds;
                        }

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Pallete.whiteColor,
                                inactiveTrackColor:
                                    Pallete.whiteColor.withOpacity(0.117),
                                thumbColor: Pallete.whiteColor,
                                trackHeight: 4,
                                overlayShape: SliderComponentShape.noOverlay,
                              ),
                              child: Slider(
                                value: sliderValue,
                                min: 0,
                                max: 1,
                                onChanged: (val) {
                                  sliderValue = val;
                                },
                                onChangeEnd: songNotifier.seek,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${position?.inMinutes ?? 0}:${(position?.inSeconds ?? 0) % 60 < 10 ? '0${(position?.inSeconds ?? 0) % 60}' : (position?.inSeconds ?? 0) % 60}',
                                  style: const TextStyle(
                                    color: Pallete.subtitleText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                                Text(
                                  '${duration?.inMinutes ?? 0}:${(duration?.inSeconds ?? 0) % 60 < 10 ? '0${(duration?.inSeconds ?? 0) % 60}' : (duration?.inSeconds ?? 0) % 60}',
                                  style: const TextStyle(
                                    color: Pallete.subtitleText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Text('Playback Speed',
                            style: TextStyle(color: Pallete.whiteColor)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButton<double>(
                            value: selectedSpeed,
                            items: playbackSpeeds.map((double speed) {
                              return DropdownMenuItem<double>(
                                value: speed,
                                child: Text(
                                  '${speed}x',
                                  style: const TextStyle(
                                    color: Pallete.subtitleText,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (double? newValue) {
                              if (newValue != null) {
                                songNotifier.audioPlayer!.setSpeed(newValue);
                                selectedSpeed = newValue;
                              }
                            },
                            dropdownColor: Pallete.backgroundColor,
                            underline: Container(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () {
                              final songNotifier = ref
                                  .read(currentSongNotifierProvider.notifier);
                              final allSongs =
                                  ref.read(getAllSongsProvider).value ?? [];

                              if (allSongs.isNotEmpty) {
                                SongModel newSong;
                                do {
                                  newSong = allSongs[
                                      Random().nextInt(allSongs.length)];
                                } while (newSong.id == songNotifier.state?.id);

                                songNotifier.updateSong(newSong);
                              }
                            },
                            child: Icon(
                              Icons.shuffle,
                              color: Pallete.whiteColor,
                              size: 35,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(currentSongNotifierProvider.notifier)
                                  .previousSong();
                            },
                            child: Image.asset(
                              'assets/images/previus-song.png',
                              color: Pallete.whiteColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: songNotifier.playPause,
                          icon: Icon(
                            songNotifier.isPlaying
                                ? CupertinoIcons.pause_circle_fill
                                : CupertinoIcons.play_circle_fill,
                          ),
                          iconSize: 80,
                          color: Pallete.whiteColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: IconButton(
                            icon: const Icon(
                              Icons.skip_next,
                              color: Pallete.whiteColor,
                              size: 45,
                            ),
                            onPressed: () {
                              final songNotifier = ref
                                  .read(currentSongNotifierProvider.notifier);

                              songNotifier.nextSong();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("⏭ Playing next song"),
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(1),
                            child: IconButton(
                              onPressed: () {
                                songNotifier.audioPlayer!.seek(Duration.zero);
                                if (!songNotifier.isPlaying) {
                                  songNotifier.playPause();
                                }
                              },
                              icon: const Icon(
                                Icons.repeat,
                                color: Pallete.whiteColor,
                                size: 35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final token = ref
                                .read(homeViewmodelProvider.notifier)
                                .getUserToken();
                            final url = Uri.parse(
                                '${ServerConstant.serverURL}/auth/subscription-status');

                            try {
                              final response = await http.get(
                                url,
                                headers: {
                                  'x-auth-token': token ?? '',
                                  'Content-Type': 'application/json',
                                },
                              );

                              if (response.statusCode == 200) {
                                final data = json.decode(response.body);
                                final planType = data["plan_type"] ?? "";

                                if (planType == "premium" ||
                                    planType == "yearly_premium") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LyricsPage(
                                        song: currentSong,
                                        songId: currentSong.id,
                                      ),
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Premium Required"),
                                      content: const Text(
                                        "Lyrics are available only for Premium and Yearly Premium subscribers.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Close"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const SubscriptionPage(),
                                              ),
                                            );
                                          },
                                          child: const Text("Upgrade"),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "❌ Error checking subscription: ${response.body}"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "❌ Failed to verify subscription: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.lyrics,
                              color: Pallete.whiteColor,
                              size: 35,
                            ),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistPage(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                              width: 25,
                              height: 90,
                              child: Icon(Icons.playlist_play,
                                  color: Pallete.whiteColor, size: 45),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension AudioPlayer3DExtension on AudioPlayer {
  void set3DAudioEnabled(bool enabled) {
    if (enabled) {
    } else {}
  }
}

void getSongLyrics(String songId) async {
  try {
    SongModel song = await SongService.fetchSong(songId);
    print(song.lyrics);
  } catch (e) {
    print('Error: $e');
  }
}
