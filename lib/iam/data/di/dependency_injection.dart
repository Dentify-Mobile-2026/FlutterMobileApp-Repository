import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dentify_flutter/iam/data/repository/auth_repository_impl.dart';
import 'package:dentify_flutter/iam/data/remote/services/auth_api_service.dart';
import 'package:dentify_flutter/iam/domain/repository/auth_repository.dart';
import '../../../core/network/api_constants.dart';

// Provider para AuthApiService
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ApiConstants.baseUrl);
});

// Provider para AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authApiServiceProvider));
});
