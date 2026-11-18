class Patient {
  final int id;
  final String dni;
  final String firstName;
  final String lastName;
  final String email;
  final String homeAddress;
  final String birthday;
  final String phone;
  final String allergies;
  final String systemicConditions;
  final String emergencyContactName;
  final String emergencyContactPhone;

  const Patient({
    required this.id,
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.homeAddress,
    required this.birthday,
    this.phone = '',
    this.allergies = '',
    this.systemicConditions = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.trim().isNotEmpty ? firstName.trim()[0] : '';
    final last = lastName.trim().isNotEmpty ? lastName.trim()[0] : '';
    final combined = '$first$last'.toUpperCase();
    return combined.isEmpty ? 'P' : combined;
  }

  bool get hasAllergies => allergies.trim().isNotEmpty;

  bool get hasSystemicConditions => systemicConditions.trim().isNotEmpty;

  bool get hasMedicalAlerts => hasAllergies || hasSystemicConditions;

  int? get age {
    final birthDate = DateTime.tryParse(birthday);
    if (birthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years >= 0 ? years : null;
  }
}
