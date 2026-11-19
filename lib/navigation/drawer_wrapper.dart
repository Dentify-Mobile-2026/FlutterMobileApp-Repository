import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DrawerWrapper extends StatelessWidget {
  final Widget content;

  const DrawerWrapper({required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          "Dentify App",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            
          ),
        ),
        backgroundColor: Colors.white,
        child: DrawerContent(
          onItemSelected: (route) {
            Navigator.of(context).pop();
            if (ModalRoute.of(context)?.settings.name != route) {
              Navigator.of(context).pushReplacementNamed(route);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: content,
      ),
    );
  }
}

class DrawerContent extends StatelessWidget {
  final Function(String) onItemSelected;

  const DrawerContent({required this.onItemSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            children: const [
              Icon(Icons.medical_services_outlined, size: 44, color: Colors.white),
              SizedBox(width: 16),
              Text(
                'Dentify',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        ..._drawerItems.map((item) {
          return ListTile(
            leading: Icon(item.icon, color: AppColors.primary),
            title: Text(
              item.label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            onTap: () => onItemSelected(item.route),
          );
        }),

        const Divider(thickness: 1, height: 32),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            "Logout",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            await TokenStorage.clearTokens();
            if (!context.mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
          },
        ),
      ],
    );
  }

  List<_DrawerItem> get _drawerItems => const [
    _DrawerItem(label: "Dashboard", icon: Icons.dashboard, route: "/home"),
    _DrawerItem(label: "Appointments", icon: Icons.calendar_today, route: "/appointments"),
    _DrawerItem(label: "Patients", icon: Icons.people, route: "/patients"),
    _DrawerItem(label: "Inventory", icon: Icons.inventory_2, route: "/inventory"),
    _DrawerItem(label: "Payments", icon: Icons.payment, route: "/payments"),
    _DrawerItem(label: "Profile", icon: Icons.person, route: "/profile"),
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
