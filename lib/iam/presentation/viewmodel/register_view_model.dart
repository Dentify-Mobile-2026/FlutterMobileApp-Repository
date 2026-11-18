import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/model/register.dart';
import '../../domain/model/login.dart';

class RegisterViewModel extends StateNotifier<Login?> {
  final RegisterUseCase registerUseCase;

  String? errorMessage;
  bool trial = false;
  String firstName = '';
  String lastName = '';
  String email = '';
  String companyName = '';
  String username = '';
  String password = '';

  RegisterViewModel(this.registerUseCase) : super(null);

  bool get isAuthenticated => state != null;

  Future<void> register() async {
    try {
      // Asegúrate de pasar todas las propiedades correctas
      final registerModel = Register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        companyName: companyName,
        username: username,
        password: password,
        trial: trial,
      );
      final response = await registerUseCase(registerModel);
      await TokenStorage.saveTokens(response.accessToken, response.refreshToken);
      state = response;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}
