import 'package:just_audio/just_audio.dart';

class AudioPlayerSingleton {
  static final AudioPlayer _instance = AudioPlayer();

  static AudioPlayer get instance => _instance;

  AudioPlayerSingleton._();
}