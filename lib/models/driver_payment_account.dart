class DriverPaymentAccount {
  const DriverPaymentAccount({
    required this.id,
    required this.name,
    required this.number,
    required this.instructions,
    required this.isActive,
  });

  final int id;
  final String name;
  final String number;
  final String instructions;
  final bool isActive;

  factory DriverPaymentAccount.fromJson(Map<String, dynamic> json) =>
      DriverPaymentAccount(
        id: int.tryParse('${json['id']}') ?? 0,
        name: '${json['name'] ?? ''}',
        number: '${json['number'] ?? ''}',
        instructions: '${json['instructions'] ?? ''}',
        isActive: json['is_active'] == true ||
            json['is_active'] == 1 ||
            '${json['is_active']}' == '1',
      );
}
