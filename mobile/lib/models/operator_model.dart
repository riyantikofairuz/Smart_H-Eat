class OperatorModel {
  final int id;
  final String name;
  final String username;
  final String? token;

  const OperatorModel({
    required this.id,
    required this.name,
    required this.username,
    this.token,
  });

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'token': token,
    };
  }
}
