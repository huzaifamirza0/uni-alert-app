class VideoFile {
  final String path;
  final String dateTime;

  VideoFile({
    required this.path,
    required this.dateTime
  });

  factory VideoFile.fromMap(Map<String, dynamic> map) {
    return VideoFile(
      path: map['path'],
      dateTime: map['dateTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'dateTime': dateTime,
    };
  }
}
