import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/core/constants/server_constant.dart';

class SongService {
  static Future<SongModel> fetchSong(String songId) async {
    final response = await http.get(Uri.parse('${ServerConstant.serverURL}/songs/$songId'));

    print("API Response: ${response.body}"); 

    if (response.statusCode == 200) {
      return SongModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load song');
    }
  }
}
