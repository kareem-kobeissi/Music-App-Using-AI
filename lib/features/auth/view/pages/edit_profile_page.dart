import 'dart:convert';

import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/features/auth/view/pages/welcome_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> updateProfile(String name, String email) async {
    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please fill in both fields.")),
      );
      return; 
    }

    
    final emailRegex = RegExp(r'\S+@\S+\.\S+');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please enter a valid email.")),
      );
      return;
    }

    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url = Uri.parse('${ServerConstant.serverURL}/auth/update-profile');

    try {
      final response = await http.put(
        url,
        headers: {
          'x-auth-token': token!,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print(result['message']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profile updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ Failed to update profile: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  Future<void> deleteAccount() async {
    bool? isConfirmed = await _showDeleteConfirmationDialog();

    if (isConfirmed == true) {
      final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
      final url = Uri.parse('${ServerConstant.serverURL}/auth/delete-account');

      try {
        final response = await http.delete(
          url,
          headers: {
            'x-auth-token': token!,
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          print(result['message']);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Account deleted successfully!")),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WelcomePage()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("❌ Failed to delete account: ${response.body}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e")),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/k.webp',
              fit: BoxFit.cover,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 5),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/lo.png',
                                  width: 120,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Pallete.whiteColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomField(
                            hintText: 'Enter your new name',
                            controller: _nameController,
                            icon: Icons.lock_outline,
                          ),
                          const SizedBox(height: 20),
                          CustomField(
                            hintText: 'Enter your new email',
                            controller: _emailController,
                            icon: Icons.lock,
                          ),
                          const SizedBox(height: 20),
                          AuthGradientButton(
                            buttonText: 'Edit Account',
                            onTap: () => updateProfile(
                              _nameController.text,
                              _emailController.text,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AuthGradientButton(
                            buttonText: 'Delete Account',
                            onTap: deleteAccount,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
