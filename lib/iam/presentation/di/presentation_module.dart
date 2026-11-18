import 'package:dentify_flutter/iam/data/di/profile_providers.dart';
import 'package:dentify_flutter/iam/presentation/viewmodel/profile_state.dart';
import 'package:dentify_flutter/iam/presentation/viewmodel/profile_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../viewmodel/login_view_model.dart';
import '../viewmodel/register_view_model.dart';
import '../../data/di/dependency_injection.dart';

// Define los providers para LoginUseCase y RegisterUseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

// Define los providers para los ViewModels
final loginViewModelProvider = Provider<LoginViewModel>((ref) {
  return LoginViewModel(ref.read(loginUseCaseProvider));
});

final registerViewModelProvider = Provider<RegisterViewModel>((ref) {
  return RegisterViewModel(ref.read(registerUseCaseProvider));
});

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(
    getUserInfoUseCase: ref.read(getUserInfoUseCaseProvider),
    updatePasswordUseCase: ref.read(updatePasswordUseCaseProvider),
    updateInformationUseCase: ref.read(updateInfoUseCaseProvider),
  );
});