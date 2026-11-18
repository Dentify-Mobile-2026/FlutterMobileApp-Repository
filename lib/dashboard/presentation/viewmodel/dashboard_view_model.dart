import 'dart:async';

import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/dashboard/domain/model/dashboard_data.dart';
import 'package:dentify_flutter/dashboard/domain/usecases/dashboard_usecase.dart';
import 'package:dentify_flutter/dashboard/presentation/di/dashboard_module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardModuleProvider = Provider<DashboardModule>(
  (ref) => DashboardModule(baseUrl: ApiConstants.baseUrl),
);

final getDashboardDataUseCaseProvider = Provider<GetDashboardDataUseCase>(
  (ref) => ref.read(dashboardModuleProvider).provideUseCase(),
);

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, AsyncValue<DashboardData>>(
  (ref) => ref.read(dashboardModuleProvider).provideViewModel(),
);

class DashboardViewModel extends StateNotifier<AsyncValue<DashboardData>> {
  final GetDashboardDataUseCase _useCase;

  DashboardViewModel(this._useCase) : super(const AsyncValue.loading()) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
  try {
    final data = await _useCase();
    state = AsyncValue.data(data);
  } catch (e, st) {
    print("❌ Error en loadDashboardData: $e");
    print("🧾 Stacktrace: $st");
    state = AsyncValue.error(e, st);
  }
}

}