import 'dart:io';

typedef Json = Map<String, dynamic>;

Future<File> createFile(String path) async {
  final file = File(path);
  await file.create(recursive: true);
  return file;
}
