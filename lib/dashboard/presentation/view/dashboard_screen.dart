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
      appBar: AppBar(title: const Text('Resumen de datos'), automaticallyImplyLeading: false),
      body: state.when(
        loading: () => const ShimmerLoading(),
        data: (data) => DashboardContent(data: data),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Error al cargar el dashboard.', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Text(e.toString(), style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
