class Patient {
  final int id;
  final String dni;
  final String firstName;
  final String lastName;
  final String email;
  final String homeAddress;
  final String birthday;

  const Patient({
    required this.id,
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.homeAddress,
    required this.birthday
  });
}