import 'dart:convert';

import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/auth/view/pages/admin_requests_page.dart';
import 'package:client/features/auth/view/pages/app_information_page.dart';
import 'package:client/features/auth/view/pages/change_password_page.dart';
import 'package:client/features/auth/view/pages/edit_profile_page.dart';
import 'package:client/features/auth/view/pages/privacy_policy_page.dart';
import 'package:client/features/auth/view/pages/song_view_users_requests.dart';
import 'package:client/features/auth/view/pages/terms_of_service_page.dart';
import 'package:client/features/auth/view/pages/welcome_page.dart';
import 'package:client/features/auth/view/pages/subscription_page.dart';
import 'package:client/features/home/view/pages/admin_update_song_page.dart';
import 'package:client/features/home/view/pages/admin_upload_song_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/features/home/view/pages/users_list_page.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();

    void animatedNavigation(BuildContext context, Widget page,
        {Offset beginOffset = const Offset(1.0, 0.0)}) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            final tween = Tween(begin: beginOffset, end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(
                position: animation.drive(tween), child: child);
          },
        ),
      );
    }

    void _navigateToSongRequests(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SongRequestsPage()),
      );
    }

    void _navigateToAdminSongRequests(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminSongRequestsPage()),
      );
    }

    Future<void> _sendSongRequest(String songName) async {
      final String? token =
          ref.read(homeViewmodelProvider.notifier).getUserToken();
      final url = Uri.parse('${ServerConstant.serverURL}/auth/request-song');

      try {
        final response = await http.post(
          url,
          headers: {
            'x-auth-token': token!,
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'song_name': songName,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Song request submitted successfully to the admin!')),
          );
        } else {
          final responseBody = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(responseBody['detail'] ?? 'Failed to request song.')),
          );
        }
      } catch (e) {
        print("Error sending song request: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting song request.')),
        );
      }
    }

    void _showRequestSongDialog(BuildContext context) {
      TextEditingController songController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Pallete.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Request a Song",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: songController,
                  style: const TextStyle(color: Pallete.whiteColor),
                  cursorColor: Pallete.whiteColor,
                  decoration: const InputDecoration(
                    hintText: 'Enter the song name...',
                    hintStyle: TextStyle(color: Pallete.subtitleText),
                    filled: true,
                    fillColor: Pallete.backgroundColor,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                AuthGradientButton(
                  buttonText: "Send Request",
                  onTap: () {
                    if (songController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a song name.')),
                      );
                      return;
                    }
                    _sendSongRequest(songController.text);
                    Navigator.pop(context); 
                  },
                  icon: CupertinoIcons.plus,
                ),
              ],
            ),
          ),
        ),
      );
    }

    Future<bool?> _showLogoutConfirmationDialog(BuildContext context) async {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Confirm Logout"),
            content: const Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), 
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout"),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Pallete.whiteColor,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Pallete.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          _buildSectionTitle('Account Settings'),
          _buildSettingItem(
            context,
            CupertinoIcons.lock,
            'Change Password',
            () => animatedNavigation(context, ChangePasswordPage()),
          ),
          _buildSettingItem(
            context,
            CupertinoIcons.pencil,
            'Edit Profile',
            () => animatedNavigation(context, EditProfilePage()),
          ),
          _buildSettingItem(
            context,
            CupertinoIcons.add,
            'Add Account',
            () => animatedNavigation(context, WelcomePage()),
          ),
          const Divider(),
          _buildSectionTitle('General Settings'),
          _buildSettingItem(
            context,
            CupertinoIcons.star_fill,
            'Rate the App',
            () {
              _showRatingDialog(context);
            },
          ),
          _buildSettingItem(
            context,
            CupertinoIcons.envelope_open_fill,
            'Send Feedback',
            () {
              _sendFeedback();
            },
          ),
          _buildSettingItem(
            context,
            CupertinoIcons.info_circle_fill,
            'App Information',
            () => animatedNavigation(context, AppInformationPage()),
          ),
          const Divider(),
          _buildSectionTitle('Legal Information'),
          _buildSettingItem(
            context,
            CupertinoIcons.lock_shield_fill,
            'Privacy Policy',
            () => animatedNavigation(context, PrivacyPolicyPage()),
          ),
          _buildSettingItem(
            context,
            CupertinoIcons.doc_on_clipboard_fill,
            'Terms of Service',
            () => animatedNavigation(context, TermsOfServicePage()),
          ),
          const Divider(),
          _buildSectionTitle('Subscription'),
          _buildSubscriptionStatusTile(context, token ?? ""),
          const Divider(),
          if (currentUser?.role != "admin") ...[
            if (currentUser?.role != "admin") ...[
              _buildSectionTitle('My Song Requests'),
              _buildSettingItem(
                context,
                CupertinoIcons.music_note,
                'View My Requests',
                () => _navigateToSongRequests(context),
              ),
            ],
            _buildSettingItem(
              context,
              CupertinoIcons.add_circled_solid,
              'Request a Song',
              () => _showRequestSongDialog(context),
            ),
          ],
          const Divider(),
          if (currentUser?.role == "admin") ...[
            _buildSectionTitle('Admin Tools'),
            _buildSettingItem(
              context,
              CupertinoIcons.music_note,
              'Upload New Song',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminUploadSongPage()),
                );
              },
            ),
            _buildSettingItem(
              context,
              CupertinoIcons.gear,
              'Manage Songs',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminSongsPage()),
                );
              },
            ),
            _buildSettingItem(
              context,
              CupertinoIcons.person_3_fill,
              'Manage Users',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UsersListPage()),
                );
              },
            ),
            _buildSettingItem(
              context,
              CupertinoIcons.music_note_list,
              'Manage Song Requests',
              () => _navigateToAdminSongRequests(context),
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Pallete.whiteColor,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Pallete.whiteColor,
                fontSize: 18,
              ),
            ),
            onTap: () async {
              final isConfirmed = await _showLogoutConfirmationDialog(context);
              if (isConfirmed == true) {
                ref.read(currentSongNotifierProvider.notifier).pause();

                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (_, __, ___) => const WelcomePage(),
                    transitionsBuilder: (_, animation, __, child) {
                      final tween = Tween(
                              begin: const Offset(-1.0, 0.0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeInOut));
                      return SlideTransition(
                          position: animation.drive(tween), child: child);
                    },
                  ),
                  (route) => false,
                );
              }
            },
            tileColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "App Version 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> fetchSubscriptionStatus(String token) async {
    final url =
        Uri.parse('${ServerConstant.serverURL}/auth/subscription-status');

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
        return data;
      }
    } catch (e) {
      print("Error fetching subscription status: $e");
    }
    return null;
  }

  Widget _buildSubscriptionStatusTile(BuildContext context, String token) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchSubscriptionStatus(token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text("Checking subscription...",
                style: TextStyle(color: Colors.white)),
          );
        }

        final subData = snapshot.data;
        final isSubscribed = subData?['is_premium'] ?? false;
        final planName = subData?['plan_name'] ?? "";

        return ListTile(
          leading: const Icon(CupertinoIcons.creditcard, color: Colors.white),
          title: Text(
            'Manage Subscription',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          subtitle: isSubscribed
              ? Text("Active Plan: $planName ✅",
                  style: const TextStyle(color: Colors.greenAccent))
              : const Text("No active subscription",
                  style: TextStyle(color: Colors.grey)),
          trailing: isSubscribed
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          tileColor: Colors.black.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionPage()),
          ),
        );
      },
    );
  }

  Widget _buildSettingItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      onTap: onTap,
      tileColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }

  void _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'beatflowsupport@hotmail.com',
      queryParameters: {
        'subject': 'Feedback for App',
        'body': 'Hi, I have some feedback regarding your app...'
      },
    );

    if (!await launchUrl(emailUri)) {
      throw 'Could not launch email client.';
    }
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Pallete.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.star_fill,
                size: 50,
                color: Pallete.gradient2,
              ),
              const SizedBox(height: 15),
              const Text(
                "Rate Our App",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enjoying our app? Give us a rating and help us improve!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(5, (index) {
                  return const Icon(
                    CupertinoIcons.star_fill,
                    color: Pallete.gradient2,
                    size: 30,
                  );
                }),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AuthGradientButton(
                      buttonText: "Send Feedback",
                      onTap: () {
                        Navigator.pop(context);
                        _sendFeedback();
                      },
                      icon: CupertinoIcons.envelope_open,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: AuthGradientButton(
                      buttonText: "Close",
                      onTap: () {
                        Navigator.pop(context);
                      },
                      icon: CupertinoIcons.clear_circled,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
