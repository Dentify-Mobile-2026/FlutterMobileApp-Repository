import 'package:dentify_flutter/iam/data/model/user_info_response.dart';
import 'package:dentify_flutter/iam/data/remote/dto/update_infomation_request.dart';
import 'package:dentify_flutter/iam/data/remote/dto/update_password_request.dart';

abstract class ProfileRepository {
  Future<UserInfoResponse> getUserInfo();
  Future<void> updatePassword(UpdatePasswordRequest request);
  Future<void> updateInformation(UpdateInformationRequest request);
}