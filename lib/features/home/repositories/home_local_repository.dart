import 'package:client/features/home/models/song_model.dart';
//Hive for local database storage
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_local_repository.g.dart';

// Riverpod provider for HomeLocalRepository
@riverpod
HomeLocalRepository homeLocalRepository(HomeLocalRepositoryRef ref) {
  // instance of HomeLocalRepository
  return HomeLocalRepository();
}

// Repository class for managing local song data using Hive
class HomeLocalRepository {
  // Reference to the Hive box named 'defaultBox'
  final Box box = Hive.box('defaultBox');

  void uploadLocalSong(String userId, SongModel song) {
    // Load the current list of songs for the user
    List<SongModel> userSongs = loadSongs(userId);
    // Insert the new song at the beginning of the list
    userSongs.insert(0, song);
    // Save the updated list back to the Hive box as JSON
    box.put(userId, userSongs.map((song) => song.toJson()).toList());
  }

  // Method to load the list of songs for a specific user
  List<SongModel> loadSongs(String? userId) {
    // If the userId is null or doesn't exist in the Hive box, return an empty list
    if (userId == null || !box.containsKey(userId)) return [];
    // Retrieve the list from the Hive box and convert it from JSON to SongModel objects
    return (box.get(userId) as List)
        .map((data) => SongModel.fromJson(data))
        .toList();
  }

  // Method to clear all songs for a specific user from the local storage
  void clearUserSongs(String userId) {
    // Delete the user's data from the Hive box
    box.delete(userId);
  }

  // Placeholder method to save an updated list of songs for a user
  void saveSongs(String userId, List<SongModel> updatedList) {
    // Implementation can be added as needed
  }
}