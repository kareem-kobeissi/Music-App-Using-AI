import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Pallete.whiteColor,
              fontSize: 23),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Pallete.whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Pallete.backgroundColor,
      ),
      backgroundColor: Pallete.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Welcome to Our Privacy Policy"),
                  _buildSectionText(
                      "This document explains how we collect, use, and protect your data while using our services."),
                  _buildSectionTitle("1. Information We Collect"),
                  _buildBulletPoint(
                      "Personal details: Name, email, phone number (if provided)."),
                  _buildBulletPoint(
                      "Device Information: Model, OS version, IP address."),
                  _buildBulletPoint(
                      "Usage Data: Interactions, preferences, and activity logs."),
                  const Divider(),
                  _buildSectionTitle("2. How We Use Your Data"),
                  _buildBulletPoint("To provide and improve our services."),
                  _buildBulletPoint("To ensure security and prevent fraud."),
                  _buildBulletPoint("To comply with legal requirements."),
                  const Divider(),
                  _buildSectionTitle("3. Your Rights"),
                  _buildBulletPoint(
                      "You have the right to access, modify, or delete your data."),
                  _buildBulletPoint(
                      "You can request a copy of the data we store about you."),
                  _buildBulletPoint(
                      "You can opt out of data collection by adjusting app settings."),
                  const Divider(),
                  _buildSectionTitle("4. Changes to This Policy"),
                  _buildSectionText(
                      "We may update this policy from time to time. Significant changes will be communicated."),
                  const SizedBox(height: 20),
                  const Divider(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: AuthGradientButton(
                    buttonText: "Back",
                    onTap: () {
                      Navigator.pop(context);
                    },
                    icon: CupertinoIcons.arrow_left,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: AuthGradientButton(
                    buttonText: "Agree",
                    onTap: () {
                      print("User agreed");
                      Navigator.pop(context);
                    },
                    icon: CupertinoIcons.checkmark_alt,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Colors.white, fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
