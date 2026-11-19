import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:flutter/material.dart';

/// Contenedor principal responsive:
/// - En pantallas anchas (>= 900px) muestra un sidebar lateral fijo minimalista.
/// - En móvil / pantallas estrechas usa un Drawer deslizable con AppBar compacto.
class DrawerWrapper extends StatelessWidget {
  final Widget content;

  const DrawerWrapper({required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/home';
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    void navigate(String route) {
      if (route == currentRoute) {
        if (!isDesktop) Navigator.of(context).pop();
        return;
      }
      Navigator.of(context).pushReplacementNamed(route);
    }

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            Container(
              width: 232,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: DrawerContent(
                currentRoute: currentRoute,
                onItemSelected: navigate,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: content,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        toolbarHeight: 54,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Dentify',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      drawer: Drawer(
        width: 256,
        backgroundColor: AppColors.surface,
        child: DrawerContent(
          currentRoute: currentRoute,
          onItemSelected: navigate,
        ),
      ),
      body: content,
    );
  }
}

class DrawerContent extends StatelessWidget {
  final String currentRoute;
  final Function(String) onItemSelected;

  const DrawerContent({
    required this.currentRoute,
    required this.onItemSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dentify',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Gestión Odontológica',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: _drawerItems.map((item) {
                final isSelected = currentRoute == item.route;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: isSelected ? AppColors.mint : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onItemSelected(item.route),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 19,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.muted,
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primaryDark
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  await TokenStorage.clearTokens();
                  if (!context.mounted) return;
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          size: 19, color: AppColors.danger),
                      SizedBox(width: 11),
                      Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_DrawerItem> get _drawerItems => const [
        _DrawerItem(
            label: 'Dashboard', icon: Icons.space_dashboard_outlined, route: '/home'),
        _DrawerItem(
            label: 'Agenda de Citas',
            icon: Icons.calendar_month_outlined,
            route: '/appointments'),
        _DrawerItem(
            label: 'Pacientes', icon: Icons.people_outline_rounded, route: '/patients'),
        _DrawerItem(
            label: 'Tratamientos',
            icon: Icons.medical_services_outlined,
            route: '/treatments'),
        _DrawerItem(
            label: 'Inventario',
            icon: Icons.inventory_2_outlined,
            route: '/inventory'),
        _DrawerItem(
            label: 'Facturación', icon: Icons.receipt_long_outlined, route: '/payments'),
        _DrawerItem(
            label: 'Mi Perfil', icon: Icons.person_outline_rounded, route: '/profile'),
      ];
}

class _DrawerItem {
  final String label;
  final IconData icon;
  final String route;

  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}
