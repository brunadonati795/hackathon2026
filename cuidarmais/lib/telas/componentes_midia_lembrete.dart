import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../tema.dart';

class ReminderPhotoAttachment extends StatelessWidget {
  const ReminderPhotoAttachment({super.key, required this.path, this.onRemove});

  final String path;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          FutureBuilder<Uint8List>(
            future: XFile(path).readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(
                  snapshot.data!,
                  key: const Key('reminder-photo-preview'),
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              }
              if (snapshot.hasError) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: Text('Foto indisponível')),
                );
              }
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
          if (onRemove != null)
            Positioned(
              right: 8,
              top: 8,
              child: IconButton.filled(
                tooltip: 'Remover foto',
                onPressed: onRemove,
                icon: const Icon(Icons.close),
              ),
            ),
        ],
      ),
    );
  }
}

class ReminderAudioAttachment extends StatefulWidget {
  const ReminderAudioAttachment({super.key, required this.path});

  final String path;

  @override
  State<ReminderAudioAttachment> createState() =>
      _ReminderAudioAttachmentState();
}

class _ReminderAudioAttachmentState extends State<ReminderAudioAttachment> {
  final player = AudioPlayer();
  bool playing = false;

  @override
  void initState() {
    super.initState();
    player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => playing = false);
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> toggle() async {
    try {
      if (playing) {
        await player.stop();
      } else {
        final source = kIsWeb
            ? UrlSource(widget.path)
            : DeviceFileSource(widget.path);
        await player.play(source);
      }
      if (mounted) setState(() => playing = !playing);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível reproduzir o áudio.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEFEAFF),
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        key: const Key('reminder-audio-player'),
        leading: IconButton.filled(
          tooltip: playing ? 'Parar áudio' : 'Ouvir áudio',
          onPressed: toggle,
          icon: Icon(playing ? Icons.stop : Icons.play_arrow),
        ),
        title: const Text(
          'Mensagem de voz do familiar',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: const Text(
          'Toque para ouvir',
          style: TextStyle(color: AppColors.muted),
        ),
      ),
    );
  }
}
