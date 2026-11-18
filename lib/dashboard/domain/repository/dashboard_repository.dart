
import 'package:dentify_flutter/dashboard/domain/model/dashboard_data.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboardData();
}

