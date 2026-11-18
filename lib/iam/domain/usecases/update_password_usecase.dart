import 'package:dentify_flutter/iam/data/remote/dto/update_password_request.dart';
import 'package:dentify_flutter/iam/domain/repository/profile_repository.dart';

class UpdatePasswordUseCase {
  final ProfileRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<void> call(UpdatePasswordRequest request) =>
      repository.updatePassword(request);
}