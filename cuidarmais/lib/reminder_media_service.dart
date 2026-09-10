import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path_util;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ReminderMediaService {
  ReminderMediaService({ImagePicker? imagePicker, AudioRecorder? recorder})
    : imagePicker = imagePicker ?? ImagePicker(),
      recorder = recorder ?? AudioRecorder();

  final ImagePicker imagePicker;
  final AudioRecorder recorder;

  Future<String?> pickPhoto(ImageSource source) async {
    final selected = await imagePicker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (selected == null || kIsWeb) return selected?.path;
    final directory = await getApplicationDocumentsDirectory();
    final extension = path_util.extension(selected.path).isEmpty
        ? '.jpg'
        : path_util.extension(selected.path);
    final destination = path_util.join(
      directory.path,
      'reminder_photo_${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    await selected.saveTo(destination);
    return destination;
  }

  Future<bool> startRecording() async {
    if (!await recorder.hasPermission()) return false;
    final directory = await getApplicationDocumentsDirectory();
    final destination = path_util.join(
      directory.path,
      'reminder_voice_${DateTime.now().microsecondsSinceEpoch}.m4a',
    );
    await recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: destination,
    );
    return true;
  }

  Future<String?> stopRecording() => recorder.stop();

  Future<void> cancelRecording() => recorder.cancel();

  void dispose() => recorder.dispose();
}
