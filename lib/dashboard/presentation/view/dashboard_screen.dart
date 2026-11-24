import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/dashboard/presentation/viewmodel/dashboard_view_model.dart';
import 'package:dentify_flutter/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:dentify_flutter/dashboard/presentation/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Esto forzará recarga cada vez que se muestra la pantalla
    ref.read(dashboardViewModelProvider.notifier).loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state.when(
        loading: () => const ShimmerLoading(),
        data: (data) => DashboardContent(data: data),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 40, color: AppColors.muted),
                const SizedBox(height: 12),
                const Text('Error al cargar el dashboard.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    )),
                const SizedBox(height: 8),
                Text(
                  e.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => ref
                      .read(dashboardViewModelProvider.notifier)
                      .loadDashboardData(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
