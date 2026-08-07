import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/themes/app_theme.dart';
import 'cores/routes/app_routes.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
