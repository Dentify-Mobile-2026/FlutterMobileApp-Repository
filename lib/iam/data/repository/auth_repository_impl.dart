import '../remote/services/auth_api_service.dart';
import '../remote/dto/login_request.dart';
import '../remote/dto/register_request.dart';
import '../../domain/model/login.dart';
import '../../domain/model/register.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;

  AuthRepositoryImpl(this.apiService);

  @override
  Future<Login> login(String username, String password) async {
    // Crear un DTO para login con parámetros nombrados
    final loginRequest = LoginRequest(username: username, password: password);

    // Hacer la solicitud a la API
    final response = await apiService.login(loginRequest);

    // Convertir la respuesta a un objeto Login
    return Login(accessToken: response.accessToken, refreshToken: response.refreshToken);
  }

  @override
  Future<Login> register(Register register) async {
    // Crear un DTO para registro con parámetros nombrados
    final registerRequest = RegisterRequest(
      firstName: register.firstName,
      lastName: register.lastName,
      email: register.email,
      companyName: register.companyName,
      username: register.username,
      password: register.password,
      trial: register.trial,
    );

    // Hacer la solicitud a la API
    final response = await apiService.register(registerRequest);

    // Convertir la respuesta a un objeto Login
    return Login(
      accessToken: response.accessToken, 
      refreshToken: response.refreshToken
    );
  }
}
