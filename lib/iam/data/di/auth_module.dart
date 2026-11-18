import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/api_constants.dart';
import '../remote/services/auth_api_service.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../repository/auth_repository_impl.dart';
import '../../../navigation/dentify_app.dart';

class AuthModule {
  static AuthApiService provideAuthApiService() {
    return AuthApiService(ApiConstants.baseUrl);
  }

  static AuthRepository provideAuthRepository() {
    return AuthRepositoryImpl(provideAuthApiService());
  }

  static LoginUseCase provideLoginUseCase() {
    return LoginUseCase(provideAuthRepository());
  }

  static RegisterUseCase provideRegisterUseCase() {
    return RegisterUseCase(provideAuthRepository());
  }

  static Widget provideAuthModule() {
    return MultiProvider(
      providers: [
        Provider<AuthApiService>(create: (_) => provideAuthApiService()),
        Provider<AuthRepository>(create: (_) => provideAuthRepository()),
        Provider<LoginUseCase>(create: (_) => provideLoginUseCase()),
        Provider<RegisterUseCase>(create: (_) => provideRegisterUseCase()),
      ],
      child: DentifyApp(), // Elimina 'const'
    );
  }

}
