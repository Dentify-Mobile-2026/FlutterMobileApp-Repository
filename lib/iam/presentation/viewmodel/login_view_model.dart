import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/model/login.dart';

class LoginViewModel extends StateNotifier<Login?> {
  final LoginUseCase loginUseCase;

  // Definir las propiedades username y password
  String username = '';
  String password = '';
  String? errorMessage;

  LoginViewModel(this.loginUseCase) : super(null);

  bool get isAuthenticated => state != null;

  // Función de login que usa username y password
  Future<void> login() async {
    errorMessage = null;
    try {
      final result = await loginUseCase(username, password);

      await TokenStorage.saveTokens(result.accessToken, result.refreshToken);
      state = result;
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}
