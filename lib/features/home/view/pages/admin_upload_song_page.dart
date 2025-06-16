import 'dart:io';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/view/widgets/audio_wave.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminUploadSongPage extends ConsumerStatefulWidget {
  const AdminUploadSongPage({super.key});

  @override
  _AdminUploadSongPageState createState() => _AdminUploadSongPageState();
}

class _AdminUploadSongPageState extends ConsumerState<AdminUploadSongPage> {
  final songNameController = TextEditingController();
  final artistController = TextEditingController();
  final lyricsController = TextEditingController();
  final genreController = TextEditingController();
  Color selectedColor = Pallete.cardColor;
  File? selectedImage;
  File? selectedAudio;
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    songNameController.dispose();
    artistController.dispose();
    lyricsController.dispose();
    super.dispose();
  }

  void selectAudio() async {
    final pickedAudio = await pickAudio();
    if (pickedAudio != null) {
      setState(() {
        selectedAudio = pickedAudio;
      });
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserNotifierProvider);

    final isLoading = ref
        .watch(homeViewmodelProvider.select((val) => val?.isLoading == true));

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/k.webp',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Pallete.whiteColor,
                size: 35,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Upload Song',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Pallete.whiteColor,
                fontSize: 23,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: "Reset Form",
                onPressed: _resetForm,
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (formKey.currentState!.validate() &&
                      selectedAudio != null &&
                      selectedImage != null) {
                    ref.read(homeViewmodelProvider.notifier).uploadSong(
                          selectedAudio: selectedAudio!,
                          selectedThumbnail: selectedImage!,
                          songName: songNameController.text,
                          artist: artistController.text,
                          selectedColor: selectedColor,
                          lyrics: '',
                          genre: genreController.text,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Song uploaded successfully!'),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(20),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    showSnackBar(context, '\u274C Missing fields!');
                  }
                },
                icon: const Icon(
                  Icons.upload,
                  color: Pallete.whiteColor,
                  size: 35,
                ),
              ),
            ],
          ),
          body: isLoading
              ? const Loader()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: selectImage,
                          child: selectedImage != null
                              ? SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : DottedBorder(
                                  dashPattern: const [10, 10],
                                  color: Pallete.whiteColor,
                                  radius: const Radius.circular(30),
                                  borderType: BorderType.RRect,
                                  strokeCap: StrokeCap.round,
                                  child: const SizedBox(
                                    height: 150,
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.folder_open, size: 40),
                                        SizedBox(height: 15),
                                        Text(
                                          'Select a thumbnail for your song!',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Pallete.whiteColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 40),
                        selectedAudio != null
                            ? AudioWave(path: selectedAudio!.path)
                            : CustomField(
                                hintText: 'Pick Song',
                                controller: null,
                                readOnly: true,
                                icon: Icons.music_note,
                                onTap: selectAudio,
                              ),
                        const SizedBox(height: 20),
                        CustomField(
                          hintText: 'Artist',
                          controller: artistController,
                          icon: Icons.person_2,
                        ),
                        const SizedBox(height: 20),
                        CustomField(
                          hintText: 'Song Name',
                          controller: songNameController,
                          icon: Icons.music_video_outlined,
                        ),
                        const SizedBox(height: 20),
                        CustomField(
                          hintText: 'Genre',
                          controller: genreController,
                          icon: Icons.music_note,
                        ),
                        const SizedBox(height: 20),
                        CustomField(
                          hintText: 'Lyrics (Optional)',
                          controller: lyricsController,
                          icon: Icons.library_music,
                        ),
                        const SizedBox(height: 20),
                        ColorPicker(
                          pickersEnabled: const {ColorPickerType.wheel: true},
                          color: selectedColor,
                          onColorChanged: (Color color) {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          heading: const Text(
                            'Select Color',
                            style: TextStyle(
                              color: Pallete.whiteColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _resetForm() {
    songNameController.clear();
    artistController.clear();
    lyricsController.clear();
    setState(() {
      selectedAudio = null;
      selectedImage = null;
      selectedColor = Pallete.cardColor;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🔄 Form reset"),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
      ),
    );
  }
}
