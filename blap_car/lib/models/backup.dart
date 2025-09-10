class Backup {
  final int? id;
  final String name;
  final String filePath;
  final int size;
  final DateTime createdAt;
  final String? description;

  Backup({
    this.id,
    required this.name,
    required this.filePath,
    required this.size,
    required this.createdAt,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'file_path': filePath,
      'size': size,
      'created_at': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory Backup.fromMap(Map<String, dynamic> map) {
    return Backup(
      id: map['id'],
      name: map['name'],
      filePath: map['file_path'],
      size: map['size'],
      createdAt: DateTime.parse(map['created_at']),
      description: map['description'],
    );
  }
}