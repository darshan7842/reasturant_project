class Order {
  final int tableId;
  final List<String> foodItems; // Change to your food item model
  final String userName;
  final double totalPrice; // Add this field
  final OrderStatus status; // Add this field for service status

  Order({
    required this.tableId,
    required this.foodItems,
    required this.userName,
    this.totalPrice = 0.0,
    this.status = OrderStatus.InService, // Default status
  });
}

enum OrderStatus {
  InService,
  Completed,
}
