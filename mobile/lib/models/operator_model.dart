class OperatorModel {
  final int operatorId;
  final String name;
  final String username;
  final String password;
  final String role;

  const OperatorModel({
    required this.operatorId,
    required this.name,
    required this.username,
    required this.password,
    this.role = 'Operator Mesin',
  });
}
