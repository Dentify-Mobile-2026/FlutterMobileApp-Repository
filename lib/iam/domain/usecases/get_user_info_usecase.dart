import 'package:dentify_flutter/iam/data/model/user_info_response.dart';
import 'package:dentify_flutter/iam/domain/repository/profile_repository.dart';

class GetUserInfoUseCase {
  final ProfileRepository repository;

  GetUserInfoUseCase(this.repository);

  Future<UserInfoResponse> call() => repository.getUserInfo();
}