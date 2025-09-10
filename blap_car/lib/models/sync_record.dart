class SyncRecord {
  final int? id;
  final String tableName;
  final int recordId;
  final String operation; // INSERT, UPDATE, DELETE
  final String data;
  final DateTime timestamp;
  final bool synced;

  SyncRecord({
    this.id,
    required this.tableName,
    required this.recordId,
    required this.operation,
    required this.data,
    required this.timestamp,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory SyncRecord.fromMap(Map<String, dynamic> map) {
    return SyncRecord(
      id: map['id'],
      tableName: map['table_name'],
      recordId: map['record_id'],
      operation: map['operation'],
      data: map['data'],
      timestamp: DateTime.parse(map['timestamp']),
      synced: map['synced'] == 1,
    );
  }
}