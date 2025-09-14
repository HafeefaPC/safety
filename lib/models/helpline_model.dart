class HelplineModel {
  final String id;
  final String name;
  final String number;
  final String category;
  final String description;
  final String icon;

  const HelplineModel({
    required this.id,
    required this.name,
    required this.number,
    required this.category,
    required this.description,
    required this.icon,
  });

  factory HelplineModel.fromJson(Map<String, dynamic> json) {
    return HelplineModel(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'category': category,
      'description': description,
      'icon': icon,
    };
  }

  @override
  String toString() {
    return 'HelplineModel(id: $id, name: $name, number: $number, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HelplineModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
