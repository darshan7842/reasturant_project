enum TableStatus { Available, Reserved, Booked }

// Model for table
class TableModel {
  int id;
  String name;
  int capacity;
  TableStatus status;

  TableModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
  });

  // Convert TableModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'status': status.toString(),
    };
  }

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      name: json['name'],
      capacity: json['capacity'],
      status: TableStatus.values.firstWhere((e) => e.toString() == json['status']),
    );
  }
}
