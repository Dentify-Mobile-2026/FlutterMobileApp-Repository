import 'package:dentify_flutter/dashboard/domain/model/dashboard_data.dart';
import 'package:dentify_flutter/dashboard/domain/repository/dashboard_repository.dart';

class GetDashboardDataUseCase {
  final DashboardRepository repository;

  GetDashboardDataUseCase(this.repository);

  Future<DashboardData> call() {
    return repository.getDashboardData();
  }
}