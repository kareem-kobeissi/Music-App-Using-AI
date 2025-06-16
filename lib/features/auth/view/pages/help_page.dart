import 'package:flutter/material.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: Pallete.whiteColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        backgroundColor: Pallete.backgroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Frequently Asked Questions"),
          _buildHelpItem(
            Icons.help_outline,
            "How do I reset my password?",
            "Go to Settings > Change Password and follow the steps.",
          ),
          _buildHelpItem(
            Icons.account_circle_outlined,
            "How do I update my profile?",
            "Navigate to Profile > Edit Profile and save changes.",
          ),
          _buildHelpItem(
            Icons.subscriptions,
            "How do I manage my subscription?",
            "Go to Settings > Subscription to modify or cancel your plan.",
          ),
          _buildHelpItem(
            Icons.settings,
            "Where can I change my preferences?",
            "Navigate to Settings > Advanced Settings to customize your experience.",
          ),
          const Divider(),
          _buildSectionTitle("Troubleshooting"),
          _buildHelpItem(
            Icons.wifi_off,
            "App not loading?",
            "Check your internet connection and restart the app.",
          ),
          _buildHelpItem(
            Icons.volume_off,
            "No sound?",
            "Ensure your device is not on silent mode and restart the app.",
          ),
          _buildHelpItem(
            Icons.download_done,
            "Downloaded songs not playing?",
            "Verify storage permissions in your device settings.",
          ),
          const Divider(),
          _buildSectionTitle("Contact Support"),
          _buildContactItem(
            Icons.email,
            "Email Support",
            "Reach out via beatflowsupport@hotmail.com",
            () {
              _launchEmail();
            },
          ),
          _buildContactItem(
            Icons.call,
            "Call Support",
            "Call our 24/7 helpline at +961 70 831 913",
            () {
              _launchPhone();
            },
          ),
          _buildContactItem(
            Icons.chat_bubble_outline,
            "Live Chat (WhatsApp)",
            "Chat with our support team instantly on WhatsApp.",
            () {
              _launchWhatsApp();
            },
          ),
          const Divider(),
          _buildSectionTitle("Guides & Tutorials"),
          _buildHelpItem(
            Icons.video_library,
            "Watch Video Tutorials",
            "Learn how to use BeatFlow with our guided tutorials.",
          ),
          _buildHelpItem(
            Icons.book,
            "User Manual",
            "Read our complete user guide for all features.",
          ),
        ],
      ),
    );
  }

  void _launchEmail() async {
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

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+96170831913');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print("Could not launch phone dialer.");
    }
  }

  void _launchWhatsApp() async {
    final String phoneNumber = "96171831913";
    final String message =
        Uri.encodeComponent("Hello, I need help with BeatFlow.");

    final Uri whatsappUri =
        Uri.parse("whatsapp://send?phone=$phoneNumber&text=$message");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch WhatsApp. Trying alternative...");

      final Uri intentUri = Uri.parse(
          "intent://send?phone=$phoneNumber&text=$message#Intent;scheme=whatsapp;package=com.whatsapp;end;");

      if (await canLaunchUrl(intentUri)) {
        await launchUrl(intentUri);
      } else {
        print("WhatsApp is not installed or cannot be launched.");
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return ListTile(
      leading: Icon(icon, color: Pallete.gradient2, size: 30),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(fontSize: 15, color: Colors.white70),
      ),
      tileColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    );
  }

  Widget _buildContactItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.greenAccent, size: 30),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 15, color: Colors.white70),
      ),
      onTap: onTap,
      tileColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    );
  }
}
