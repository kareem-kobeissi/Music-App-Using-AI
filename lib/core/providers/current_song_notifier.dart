import 'dart:math';

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/viewmodel/singleton.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';

part 'current_song_notifier.g.dart';


//handles the core functionality of playing, pausing, seeking, and managing song playback in a music player app.
@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  late HomeLocalRepository _homeLocalRepository;
  final AudioPlayer singletonAudioPlayer = AudioPlayerSingleton.instance;

  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  SongModel? lastPlayedSong;
  List<SongModel> allSongs = [];


  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  void updateSong(SongModel song) async {
    await audioPlayer?.stop();
    audioPlayer = AudioPlayer();

    final audioSource = AudioSource.uri(
      Uri.parse(song.song_url),
      tag: MediaItem(
        id: song.id,
        title: song.song_name,
        artist: song.artist,
        artUri: Uri.parse(song.thumbnail_url),
      ),
    );
    await audioPlayer!.setAudioSource(audioSource);

    audioPlayer!.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        audioPlayer!.seek(Duration.zero);
        audioPlayer!.pause();
        isPlaying = false;
        this.state = this.state?.copyWith(hex_code: this.state?.hex_code);
      }
    });

    lastPlayedSong = state;

    final userId = ref.read(currentUserNotifierProvider)?.id;
    if (userId != null) {
      _homeLocalRepository.uploadLocalSong(userId, song);
    }

    audioPlayer!.play();
    isPlaying = true;
    state = song;
  }

  void playPause() {
    if (isPlaying) {
      audioPlayer?.pause();
    } else {
      audioPlayer?.play();
    }
    isPlaying = !isPlaying;
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  void seek(double val) {
    audioPlayer!.seek(
      Duration(
        milliseconds: (val * audioPlayer!.duration!.inMilliseconds).toInt(),
      ),
    );
  }

  void previousSong() async {
    print("⏮ Attempting to play previous song...");

    if (lastPlayedSong != null) {
      updateSong(lastPlayedSong!);
    } else {
      print("❌ No previous song available.");
    }
  }

  void pause() {
    audioPlayer?.pause();
    isPlaying = false;
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  void nextSong() async {
    print("⏭ Attempting to play next song...");
    // Logic to fetch the next song from your list (e.g., from all songs)
    final allSongs = ref.read(getAllSongsProvider).value ?? [];

    if (allSongs.isNotEmpty) {
      SongModel nextSong;
      do {
        nextSong = allSongs[Random().nextInt(allSongs.length)];
      } while (nextSong.id == state?.id); // Ensure the same song doesn't repeat

      updateSong(nextSong);
      print("Next song: ${nextSong.song_name}");
    } else {
      print("❌ No songs available.");
    }
  }

  getRecentlyPlayedSongs() {}
}
