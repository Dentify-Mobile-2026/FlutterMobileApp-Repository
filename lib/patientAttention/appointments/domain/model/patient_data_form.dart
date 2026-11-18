class PatientDataForm {
  final int id;
  final String firstName;
  final String lastName;

  PatientDataForm({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory PatientDataForm.fromJson(Map<String, dynamic> json) {
    return PatientDataForm(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}