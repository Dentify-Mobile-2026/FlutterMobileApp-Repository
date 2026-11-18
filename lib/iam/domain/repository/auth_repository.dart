import '../../domain/model/login.dart';
import '../../domain/model/register.dart';

abstract class AuthRepository {
  Future<Login> login(String username, String password);
  Future<Login> register(Register register);

}

