import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class FileSharingService {
  static final FileSharingService _fileSharingService = FileSharingService._internal();
  factory FileSharingService() => _fileSharingService;
  FileSharingService._internal();

  Future<void> shareFile(String filePath, String title) async {
    final file = File(filePath);
    if (await file.exists()) {
      await Share.shareXFiles([XFile(filePath)], text: title);
    } else {
      throw Exception('File not found: $filePath');
    }
  }

  Future<void> shareText(String text, String subject) async {
    await Share.share(text, subject: subject);
  }

  Future<String> getTemporaryDirectoryPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<String> getApplicationDocumentsDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}