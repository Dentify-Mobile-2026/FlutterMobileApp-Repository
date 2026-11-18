import 'package:dentify_flutter/iam/data/model/user_info_response.dart';

class ProfileState {
  final UserInfoResponse? userInfo;
  final String? errorMessage;
  final bool isLoading;

  ProfileState({this.userInfo, this.errorMessage, this.isLoading = false});

  ProfileState copyWith({
    UserInfoResponse? userInfo,
    String? errorMessage,
    bool? isLoading,
  }) {
    return ProfileState(
      userInfo: userInfo ?? this.userInfo,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}