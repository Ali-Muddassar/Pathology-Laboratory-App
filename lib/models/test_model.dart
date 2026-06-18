// lib/models/test_model.dart
class TestComponent {
  final String name;
  final String? unit;
  final double? minRange;
  final double? maxRange;
  final bool isQualitative;

  TestComponent({
    required this.name,
    this.unit,
    this.minRange,
    this.maxRange,
    this.isQualitative = false,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'unit': unit,
    'minRange': minRange,
    'maxRange': maxRange,
    'isQualitative': isQualitative,
  };

  factory TestComponent.fromMap(Map<String, dynamic> map) => TestComponent(
    name: map['name'],
    unit: map['unit'],
    minRange: map['minRange'],
    maxRange: map['maxRange'],
    isQualitative: map['isQualitative'] ?? false,
  );

  TestComponent copyWith({
    String? name,
    String? unit,
    double? minRange,
    double? maxRange,
    bool? isQualitative,
  }) {
    return TestComponent(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      minRange: minRange ?? this.minRange,
      maxRange: maxRange ?? this.maxRange,
      isQualitative: isQualitative ?? this.isQualitative,
    );
  }
}

class Test {
  final String name;
  final String? shortName;
  final String type; // 'simple', 'panel', 'detailed'
  final double price;
  final bool isQualitative;
  final String? unit;
  final double? minRange;
  final double? maxRange;
  final List<TestComponent> components;

  Test({
    required this.name,
    this.shortName,
    required this.type,
    required this.price,
    this.isQualitative = false,
    this.unit,
    this.minRange,
    this.maxRange,
    this.components = const [],
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'shortName': shortName,
    'type': type,
    'price': price,
    'isQualitative': isQualitative,
    'unit': unit,
    'minRange': minRange,
    'maxRange': maxRange,
    'components': components.map((c) => c.toMap()).toList(),
  };

  factory Test.fromMap(Map<String, dynamic> map) => Test(
    name: map['name'],
    shortName: map['shortName'],
    type: map['type'],
    price: map['price'],
    isQualitative: map['isQualitative'] ?? false,
    unit: map['unit'],
    minRange: map['minRange'],
    maxRange: map['maxRange'],
    components: (map['components'] as List?)?.map((c) => TestComponent.fromMap(c)).toList() ?? [],
  );

  bool get isPanel => type == 'panel' || type == 'detailed';
}