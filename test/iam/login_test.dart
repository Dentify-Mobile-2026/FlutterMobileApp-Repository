import 'package:dentify_flutter/iam/domain/model/login.dart';
import 'package:dentify_flutter/iam/domain/model/register.dart';
import 'package:dentify_flutter/iam/domain/repository/auth_repository.dart';
import 'package:dentify_flutter/iam/domain/usecases/login_use_case.dart';
import 'package:dentify_flutter/iam/presentation/view/login.dart';
import 'package:dentify_flutter/iam/presentation/viewmodel/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tapping Login calls the login use case', (tester) async {
    final repository = _FakeAuthRepository();
    var didLogin = false;
    final viewModel = LoginViewModel(LoginUseCase(repository));

    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          viewModel: viewModel,
          onLogin: () => didLogin = true,
          toRegister: () {},
        ),
      ),
    );

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'dentist');
    await tester.enterText(textFields.at(1), 'secret');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(repository.username, 'dentist');
    expect(repository.password, 'secret');
    expect(didLogin, isTrue);
  });
}

class _FakeAuthRepository implements AuthRepository {
  String? username;
  String? password;

  @override
  Future<Login> login(String username, String password) async {
    this.username = username;
    this.password = password;
    return Login(accessToken: 'access', refreshToken: 'refresh');
  }

  @override
  Future<Login> register(Register register) {
    throw UnimplementedError();
  }
}
