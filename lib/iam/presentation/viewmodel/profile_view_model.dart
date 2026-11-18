import 'package:dentify_flutter/iam/data/remote/dto/update_infomation_request.dart';
import 'package:dentify_flutter/iam/data/remote/dto/update_password_request.dart';
import 'package:dentify_flutter/iam/domain/usecases/get_user_info_usecase.dart';
import 'package:dentify_flutter/iam/domain/usecases/update_information_usecase.dart';
import 'package:dentify_flutter/iam/domain/usecases/update_password_usecase.dart';
import 'package:dentify_flutter/iam/presentation/viewmodel/profile_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetUserInfoUseCase getUserInfoUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final UpdateInformationUseCase updateInformationUseCase;

  ProfileViewModel({
    required this.getUserInfoUseCase,
    required this.updatePasswordUseCase,
    required this.updateInformationUseCase,
  }) : super(ProfileState());

  Future<void> fetchUserInfo() async {
  try {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await getUserInfoUseCase();
    state = state.copyWith(userInfo: result, errorMessage: null, isLoading: false);
  } catch (e) {
    state = state.copyWith(errorMessage: 'Error fetching user info: ${e.toString()}', isLoading: false);
  }
}

  Future<void> updatePassword(UpdatePasswordRequest request) async {
    try {
      await updatePasswordUseCase(request);
      state = state.copyWith(errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Password update failed: ${e.toString()}');
    }
  }

  Future<void> updateInformation(UpdateInformationRequest request) async {
    try {
      await updateInformationUseCase(request);
      await fetchUserInfo();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Information update failed: ${e.toString()}');
    }
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
