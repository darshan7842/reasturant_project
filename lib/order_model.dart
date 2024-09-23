import 'dart:convert'; // For JSON serialization

class Order {
  int tableId;
  String userName;
  List<String> foodItems; // Assuming food items are stored as a list of strings
  double totalPrice;

  Order({
    required this.tableId,
    required this.userName,
    required this.foodItems,
    required this.totalPrice,
  });

  // Convert Order instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'userName': userName,
      'foodItems': foodItems, // Convert list of food items to JSON
      'totalPrice': totalPrice,
    };
  }

  // Convert JSON to Order instance
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      tableId: json['tableId'],
      userName: json['userName'],
      foodItems: List<String>.from(json['foodItems']), // Convert JSON list to List<String>
      totalPrice: json['totalPrice'].toDouble(), // Ensure totalPrice is a double
    );
  }
}
