import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:client/core/constants/server_constant.dart';

class SongRequestsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  SongRequestsNotifier() : super([]);

  Future<void> fetchAllSongRequests(String token) async {
    final url = Uri.parse('${ServerConstant.serverURL}/auth/admin/song-requests');

    try {
      final response = await http.get(
        url,
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        state = List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print("Error fetching song requests: $e");
    }
  }




  Future<void> confirmSongRequest(String requestId, String token) async {
    final url = Uri.parse('${ServerConstant.serverURL}/auth/admin/confirm-song-request/$requestId');

    try {
      final response = await http.put(
        url,
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        state = state.map((request) {
          if (request['id'] == requestId) {
            return {...request, 'status': 'confirmed'};
          }
          return request;
        }).toList();
      } else {
        print("Error confirming song request: ${response.body}");
      }
    } catch (e) {
      print("Error confirming song request: $e");
    }
  }
}