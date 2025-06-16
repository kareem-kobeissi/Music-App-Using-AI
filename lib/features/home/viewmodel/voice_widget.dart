import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/home/viewmodel/voice_controller.dart';
import 'package:flutter/material.dart';

class VoiceControlWidget extends StatefulWidget {
  const VoiceControlWidget({Key? key}) : super(key: key);

  @override
  State<VoiceControlWidget> createState() => _VoiceControlWidgetState();
}

class _VoiceControlWidgetState extends State<VoiceControlWidget> {
  final VoiceController voiceController = VoiceController();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await voiceController.startListening(context);
      },
      icon: const Icon(Icons.mic),
      label: const Text("🎤 Speak to Play"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Pallete.gradient2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
