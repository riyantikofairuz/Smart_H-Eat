class OperatorModel {
  final int operatorId;
  final String name;
  final String username;
  final String password;
  final String? token;
  final String role;

  int get id => operatorId;

  const OperatorModel({
    int? id,
    int? operatorId,
    required this.name,
    required this.username,
    String? password,
    this.token,
    this.role = 'Operator Mesin',
  })  : operatorId = operatorId ?? id ?? 0,
        password = password ?? '';

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    final parsedId = (json['operator_id'] ?? json['id']) as int? ?? 0;
    return OperatorModel(
      operatorId: parsedId,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      token: json['token'] as String?,
      role: json['role'] as String? ?? 'Operator Mesin',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': operatorId,
      'operator_id': operatorId,
      'name': name,
      'username': username,
      'password': password,
      'token': token,
      'role': role,
    };
  }
}
