import 'package:dentify_flutter/iam/data/remote/dto/update_infomation_request.dart';
import 'package:dentify_flutter/iam/domain/repository/profile_repository.dart';

class UpdateInformationUseCase {
  final ProfileRepository repository;

  UpdateInformationUseCase(this.repository);

  Future<void> call(UpdateInformationRequest request) =>
      repository.updateInformation(request);
}