class CustomerModel {
  int id;
  String name;
  String contact;
  String? email;
  String? image;

  CustomerModel({
    required this.id,
    required this.name,
    required this.contact,
    this.email,
    this.image,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'],
        name: json['name'],
        contact: json['contact'],
        email: json['email'],
        image: json['image'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contact': contact,
        'email': email,
        'image': image,
      };

  // Method to create a copy of the current instance with modified fields
  // This is useful for immutability and updating specific fields
  CustomerModel copyWith({
    int? id,
    String? name,
    String? contact,
    String? email,
    String? image,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      image: image ?? this.image,
    );
  }
}
