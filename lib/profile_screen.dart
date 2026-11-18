// lib/profile_screen.dart

import 'package:dentify_flutter/iam/presentation/navigation/profile_nav_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Navigator(
      initialRoute: 'profile',
      onGenerateRoute: (settings) {
        final routes = profileNavGraph(ref);

        final builder = routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        }
        // fallback: página no encontrada
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('404 - Página no encontrada')),
          ),
        );
      },
    );
  }
}
