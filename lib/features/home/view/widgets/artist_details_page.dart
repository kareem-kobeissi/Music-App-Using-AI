import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/home/view/widgets/artist_model.dart';
import 'package:flutter/material.dart';

class ArtistDetailsPage extends StatelessWidget {
  final Artist artist;

  const ArtistDetailsPage({Key? key, required this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Pallete.backgroundColor,
        title: Text(
          'Welcome to ${artist.name}',
          style: const TextStyle(
              color: Pallete.whiteColor,
              fontSize: 23,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Pallete.whiteColor, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    artist.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Pallete.whiteColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Pallete.subtitleText),
            const SizedBox(height: 20),
            const SizedBox(height: 30),
            Text(
              'Biography:',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Pallete.whiteColor,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Pallete.backgroundColor.withOpacity(0.7),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  artist.bio,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Pallete.subtitleText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
