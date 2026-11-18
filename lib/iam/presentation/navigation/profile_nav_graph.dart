import 'package:dentify_flutter/iam/presentation/view/profile_view.dart';
import 'package:dentify_flutter/iam/presentation/view/update_information_view.dart';
import 'package:dentify_flutter/iam/presentation/view/update_password_view.dart';
import 'package:dentify_flutter/iam/presentation/di/presentation_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<String, WidgetBuilder> profileNavGraph(WidgetRef ref) {
  final viewModel = ref.read(profileViewModelProvider.notifier);


  return {
    'profile': (context) => ProfileView(viewModel: viewModel),
    'update-info': (context) => UpdateInformationView(viewModel: viewModel),
    'update-password': (context) => UpdatePasswordView(viewModel: viewModel),
  };
}
// 