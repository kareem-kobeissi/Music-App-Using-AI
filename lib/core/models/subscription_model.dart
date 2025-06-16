class SubscriptionPlan {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationDays;

  SubscriptionPlan({required this.id, required this.name, required this.description, required this.price, required this.durationDays});

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      durationDays: json['duration_days'],
    );
  }
}
