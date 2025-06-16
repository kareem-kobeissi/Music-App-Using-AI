import 'dart:convert';
import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class AdminSongRequestsPage extends ConsumerStatefulWidget {
  const AdminSongRequestsPage({super.key});

  @override
  ConsumerState<AdminSongRequestsPage> createState() =>
      _AdminSongRequestsPageState();
}

class _AdminSongRequestsPageState extends ConsumerState<AdminSongRequestsPage> {
  late Future<List<Map<String, dynamic>>> _songRequestsFuture;

  @override
  void initState() {
    super.initState();
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    _songRequestsFuture = fetchAllSongRequests(token ?? "");
  }

  Future<List<Map<String, dynamic>>> fetchAllSongRequests(String token) async {
    final url =
        Uri.parse('${ServerConstant.serverURL}/auth/admin/song-requests');

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

  Future<void> confirmSongRequest(String requestId, String token) async {
    final url = Uri.parse(
        '${ServerConstant.serverURL}/auth/admin/confirm-song-request/$requestId');

    try {
      final response = await http.put(
        url,
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _songRequestsFuture = fetchAllSongRequests(
              ref.read(homeViewmodelProvider.notifier).getUserToken() ?? "");
        });
      } else {
        print("Error confirming song request: ${response.body}");
      }
    } catch (e) {
      print("Error confirming song request: $e");
    }
  }

  Future<void> rejectSongRequest(String requestId, String token) async {
    final url = Uri.parse(
        '${ServerConstant.serverURL}/auth/admin/reject-song-request/$requestId');

    try {
      final response = await http.put(
        url,
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _songRequestsFuture = fetchAllSongRequests(
              ref.read(homeViewmodelProvider.notifier).getUserToken() ?? "");
        });
      } else {
        print("Error rejecting song request: ${response.body}");
      }
    } catch (e) {
      print("Error rejecting song request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        title: const Text(
          'Song Requests',
          style: TextStyle(
              color: Pallete.whiteColor,
              fontSize: 23,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Pallete.backgroundColor,
        elevation: 0,
        actions: [],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _songRequestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching song requests'));
          }

          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(child: Text('No song requests found.'));
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
                      color: Colors.white,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: Pallete.whiteColor,
                            size: 30,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'Confirm Approval',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                content: const Text(
                                  'Are you sure you want to approve this song request?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Pallete.backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                        context), 
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); 
                                      confirmSongRequest(
                                          request['id'], token ?? "");
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Song request approved!')),
                                      );
                                    },
                                    child: const Text(
                                      'Approve',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 30,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'Reject Song Request',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                content: const Text(
                                  'Are you sure you want to reject this song request?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Pallete.backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                        context), 
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); 
                                      rejectSongRequest(
                                          request['id'], token ?? "");
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Song request rejected!')),
                                      );
                                    },
                                    child: const Text(
                                      'Reject',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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
