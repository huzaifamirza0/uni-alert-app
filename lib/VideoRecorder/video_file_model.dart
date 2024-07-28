class VideoFile {
  final int id;
  final String path;
  final String dateTime;

  VideoFile({
    required this.id,
    required this.path,
    required this.dateTime
  });

  factory VideoFile.fromMap(Map<String, dynamic> map) {
    return VideoFile(
      id: map['id'],
      path: map['path'],
      dateTime: map['dateTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'dateTime': dateTime,
    };
  }
}
