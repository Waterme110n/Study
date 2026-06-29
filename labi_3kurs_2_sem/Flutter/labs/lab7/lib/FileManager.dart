import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Messager.dart';

class FileManager {
  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;

    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> writeUserData(User user, String directoryType) async {
    await requestStoragePermission();
    Directory? directory;
    switch (directoryType) {
      case 'Temporary':
        directory = await getTemporaryDirectory();
        break;
      case 'Application Documents':
        directory = await getApplicationDocumentsDirectory();
        break;
      case 'Application Support':
        directory = await getApplicationSupportDirectory();
        break;
      case 'Application Library':
        directory = await getLibraryDirectory();
        break;
      case 'Application Cache':
        directory = await getApplicationCacheDirectory();
        break;
      case 'External Storage':
        directory = await getExternalStorageDirectory();
        break;
      case 'External Cache Directories':
        final externalCacheDirs = await getExternalCacheDirectories();
        directory = (externalCacheDirs != null && externalCacheDirs.isNotEmpty)
            ? externalCacheDirs.first
            : null;
        break;
      case 'External Storage Directories':
        final externalStorageDirs = await getExternalStorageDirectories(type: StorageDirectory.documents);
        directory = (externalStorageDirs != null && externalStorageDirs.isNotEmpty)
            ? externalStorageDirs.first
            : null;
        break;
      case 'Downloads':
        directory = await getDownloadsDirectory();
    }

    if (directory != null) {
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/${user.id}_user.txt');
      await file.writeAsString('Имя: ${user.name}\nEmail: ${user.email}\nСтатус: ${user.status}');
    } else {
      throw Exception('Директория не найдена');
    }
  }

  Future<String> readUserData(String userId, String directoryType) async {
    Directory? directory;
    switch (directoryType) {
      case 'Temporary':
        directory = await getTemporaryDirectory();
        break;
      case 'Application Documents':
        directory = await getApplicationDocumentsDirectory();
        break;
      case 'Application Support':
        directory = await getApplicationSupportDirectory();
        break;
      case 'Application Library':
        directory = await getLibraryDirectory();
        break;
      case 'Application Cache':
        directory = await getApplicationCacheDirectory();
        break;
      case 'External Storage':
        directory = await getExternalStorageDirectory();
        break;
      case 'External Cache Directories':
        final externalCacheDirs = await getExternalCacheDirectories();
        directory = (externalCacheDirs != null && externalCacheDirs.isNotEmpty)
            ? externalCacheDirs.first
            : null;
        break;
      case 'External Storage Directories':
        final externalStorageDirs = await getExternalStorageDirectories(type: StorageDirectory.documents);
        directory = (externalStorageDirs != null && externalStorageDirs.isNotEmpty)
            ? externalStorageDirs.first
            : null;
        break;
      case 'Downloads':
        directory = await getDownloadsDirectory();
    }

    if (directory != null) {
      final file = File('${directory.path}/${userId}_user.txt');

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        throw Exception('Файл не найден');
      }
    } else {
      throw Exception('Директория не найдена');
    }
  }
}