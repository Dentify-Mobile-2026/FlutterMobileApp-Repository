import '../../domain/model/login.dart';
import '../repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Login> call(String username, String password) async {
    return repository.login(username, password);
  }
}
