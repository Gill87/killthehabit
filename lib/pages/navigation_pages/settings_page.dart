import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';
import 'package:rehabit/components/settings_switch_tile.dart';
import 'package:rehabit/components/settings_tile.dart';
import 'package:rehabit/themes/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeCubit themeCubit = context.watch<ThemeCubit>();
    bool isDarkMode = themeCubit.isDarkMode;

    return Scaffold(
      body: Column(
        children: [
          SettingsSwitchTile(
            title: 'Dark Mode',
            icon: Icons.dark_mode,
            value: isDarkMode,
            onChanged: (value) {
              // Handle dark mode toggle
              themeCubit.toggleTheme();
            },
          ),

          SettingsTile(
            title: 'Logout',
            icon: Icons.logout,
            onTap: () {
              AuthCubit authCubit = context.read<AuthCubit>();
              authCubit.logout();
            },
          ),

        ],
      ),
    );
  }
}