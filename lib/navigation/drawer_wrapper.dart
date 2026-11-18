import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:flutter/material.dart';

class DrawerWrapper extends StatelessWidget {
  final Widget content;

  const DrawerWrapper({required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FFFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          "Dentify App",
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
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
            Navigator.of(context).pushNamed(route);
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

  const DrawerContent({required this.onItemSelected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFD1F2EB),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            children: const [
              Icon(Icons.account_circle, size: 48, color: Color(0xFF2C3E50)),
              SizedBox(width: 16),
              Text(
                'Dentify App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        ..._drawerItems.map((item) {
          return ListTile(
            leading: Icon(item.icon, color: const Color(0xFF2C3E50)),
            title: Text(
              item.label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            onTap: () => onItemSelected(item.route),
          );
        }).toList(),

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
          onTap: () {
            TokenStorage.clearTokens();
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
