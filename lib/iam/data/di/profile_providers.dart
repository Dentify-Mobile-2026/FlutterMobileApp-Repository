
import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/iam/data/remote/services/profile_api_service.dart';
import 'package:dentify_flutter/iam/data/repository/profile_repository_impl.dart';
import 'package:dentify_flutter/iam/domain/repository/profile_repository.dart';
import 'package:dentify_flutter/iam/domain/usecases/get_user_info_usecase.dart';
import 'package:dentify_flutter/iam/domain/usecases/update_information_usecase.dart';
import 'package:dentify_flutter/iam/domain/usecases/update_password_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileApiServiceProvider = Provider<ProfileApiService>((ref) {
  return ProfileApiService(ApiConstants.baseUrl);
});


final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.read(profileApiServiceProvider));
});


final getUserInfoUseCaseProvider = Provider<GetUserInfoUseCase>((ref) {
  return GetUserInfoUseCase(ref.read(profileRepositoryProvider));
});

final updateInfoUseCaseProvider = Provider<UpdateInformationUseCase>((ref) {
  return UpdateInformationUseCase(ref.read(profileRepositoryProvider));
});

final updatePasswordUseCaseProvider = Provider<UpdatePasswordUseCase>((ref) {
  return UpdatePasswordUseCase(ref.read(profileRepositoryProvider));
});