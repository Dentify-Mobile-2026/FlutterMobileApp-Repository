import 'package:dentify_flutter/iam/data/model/user_info_response.dart';
import 'package:dentify_flutter/iam/data/remote/dto/update_infomation_request.dart';
import 'package:dentify_flutter/iam/data/remote/dto/update_password_request.dart';
import 'package:dentify_flutter/iam/data/remote/services/profile_api_service.dart';
import 'package:dentify_flutter/iam/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiService api;

  ProfileRepositoryImpl(this.api);

  @override
  Future<UserInfoResponse> getUserInfo() => api.getUserInfo();

  @override
  Future<void> updatePassword(UpdatePasswordRequest request) =>
      api.updatePassword(request);

  @override
  Future<void> updateInformation(UpdateInformationRequest request) =>
      api.updateInformation(request);
}