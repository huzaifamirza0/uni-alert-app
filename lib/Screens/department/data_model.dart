class Department {
  final String name;
  final int userCount;
  final String code;
  final String creationDate;
  final String picture;

  Department({
    required this.name,
    required this.userCount,
    required this.code,
    required this.creationDate,
    required this.picture,
  });
}


class Batch {
  final String batchId;
  final String batch;
  final DateTime createdAt;
  final String name;
  final int userCount;
  final String picture;
  Batch({
    required this.batchId,
    required this.batch,
    required this.createdAt,
    required this.name,
    required this.userCount,
    required this.picture,
  });
}

class AdminOffice {
  final String name;
  final int userCount;
  final String description;
  final String creationDate;
  final String picture;

  AdminOffice({
    required this.name,
    required this.userCount,
    required this.description,
    required this.creationDate,
    required this.picture,
  });
}