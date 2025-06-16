import 'dart:convert';

import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class SongRequestsPage extends ConsumerWidget {
  const SongRequestsPage({super.key});

  Future<List<Map<String, dynamic>>> fetchUserRequests(String token) async {
    final url =
        Uri.parse('${ServerConstant.serverURL}/auth/user-song-requests');

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
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print("Error fetching song requests: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Song Requests',
          style: TextStyle(
              color: Pallete.whiteColor,
              fontSize: 23,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Pallete.whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Pallete.backgroundColor,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUserRequests(token ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching song requests'));
          }

          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(
                child: Text('No song requests found.',
                    style: TextStyle(
                      color: Pallete.errorColor,
                      fontSize: 18,
                    )));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      request['song_name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Pallete.whiteColor,
                      ),
                    ),
                    subtitle: Text(
                      'Status: ${request['status']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: request['status'] == 'pending'
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                    leading: const Icon(
                      CupertinoIcons.music_note,
                      color: Pallete.whiteColor,
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
