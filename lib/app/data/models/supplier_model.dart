class SupplierModel {
  final int id;
  final String name;
  final String contact;
  final String email;
  final String? image;

  SupplierModel({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    this.image,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contact': contact,
        'email': email,
        'image': image,
      };

  SupplierModel copyWith({
    int? id,
    String? name,
    String? contact,
    String? email,
    String? image,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      image: image ?? this.image,
    );
  }
}
