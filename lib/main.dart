import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'providers/portfolio_provider.dart';
import 'utils/theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PortfolioProvider(storageService),
        ),
      ],
      child: const HuVangApp(),
    ),
  );
}

class HuVangApp extends StatelessWidget {
  const HuVangApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.select<PortfolioProvider, dynamic>((p) => p.settings);
    final isDark = settings.themeMode != 'light';

    return MaterialApp(
      title: 'Hũ Vàng — Gold Portfolio',
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
