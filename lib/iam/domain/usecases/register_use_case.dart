import '../../domain/model/login.dart';
import '../../domain/model/register.dart';
import '../repository/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Login> call(Register register) async {
    return repository.register(register);
  }
}
