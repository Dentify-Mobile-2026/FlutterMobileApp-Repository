class UpdatePasswordRequest {
  final String newPassword;
  final String oldPassword;

  UpdatePasswordRequest({
    required this.newPassword,
    required this.oldPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'newPassword': newPassword,
      'oldPassword': oldPassword,
    };
  }
}
