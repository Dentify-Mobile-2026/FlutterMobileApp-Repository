import 'package:dentify_flutter/dashboard/data/remote/repository/dashboard_service.dart';
import 'package:dentify_flutter/dashboard/data/repository/dashboard_repository_impl.dart';
import 'package:dentify_flutter/dashboard/domain/usecases/dashboard_usecase.dart';
import 'package:dentify_flutter/dashboard/presentation/viewmodel/dashboard_view_model.dart';

class DashboardModule {
  final String baseUrl;

  DashboardModule({required this.baseUrl});

  late final DashboardApiService _apiService = DashboardApiService(baseUrl);
  late final DashboardRepositoryImpl _repository = DashboardRepositoryImpl(_apiService);
  late final GetDashboardDataUseCase _useCase = GetDashboardDataUseCase(_repository);
  late final DashboardViewModel _viewModel = DashboardViewModel(_useCase);

  GetDashboardDataUseCase provideUseCase() => _useCase;
  DashboardViewModel provideViewModel() => _viewModel;
}