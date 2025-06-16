import 'package:client/core/theme/app_pallette.dart';
import 'package:flutter/material.dart';

class AppInformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Information',
          style: TextStyle(color: Pallete.whiteColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Pallete.whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Pallete.borderColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📱 App Name: BeatFlow™!",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "🆚 Version: 1.0.0",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              "👨‍💻 Developed by: Kareem Kobeissi ",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              "📅 Release Date: June 2025",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Divider(color: Colors.white54),
            const SizedBox(height: 10),
            const Text(
              "📖 Description:\nThis is an advanced music player app with AI-based Voice Commands, a beautiful UI, and seamless music playback. Enjoy unlimited songs, playlists, and advanced settings to customize your experience!",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white54),
            const SizedBox(height: 10),
            const Text(
              "🔹 Features:",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem("🎵 AI Voice Commands"),
            _buildFeatureItem("🎧 High-Quality Streaming"),
            _buildFeatureItem("📂 Personalized Playlists"),
            _buildFeatureItem("🔒 Secure User Authentication"),
            _buildFeatureItem("⚙ Advanced Equalizer Settings"),
            const Divider(color: Colors.white54),
            const SizedBox(height: 20),
            const Text(
              "📞 Support & Contact:",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem("📧 Email: beatflowsupport@hotmail.com"),
            _buildFeatureItem("🌐 Website: www.beatflow.com"),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
