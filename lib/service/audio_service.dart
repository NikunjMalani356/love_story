import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';

class AudioRecorder {
  AudioRecorder._privateConstructor();

  static final AudioRecorder instance = AudioRecorder._privateConstructor();
  final RecorderController recorderController = RecorderController();

  Future<void> startRecording(String filePath) async {
    final isPermissionGranted = recorderController.hasPermission;
    'isPermissionGranted --> $isPermissionGranted'.logs();
    if (isPermissionGranted) {
      await recorderController.record(path: filePath);
    }
  }

  Future<String?> stopRecording() async {
    if (recorderController.isRecording) {
      final recordedFilePath = await recorderController.stop();
      return recordedFilePath;
    }
    return null;
  }
}
