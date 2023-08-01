import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key, required this.onHomePressed});

  final VoidCallback onHomePressed;

  void goToHomeScreen(BuildContext context) {
    onHomePressed(); // Gọi callback để quay về màn hình TabsScreen
    Navigator.pop(context); // Đóng Drawer
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                ),
                const SizedBox(width: 18),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              size: 34,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Home',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 20),
            ),
            onTap: () {
              goToHomeScreen(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.key_outlined,
              size: 34,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'API Key',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 20),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.auto_fix_high,
              size: 34,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Version',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 20),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
