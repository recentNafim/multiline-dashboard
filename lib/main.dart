import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/cart_controller.dart';
import 'controllers/product_controller.dart';
import 'pages/dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(CartController(), permanent: true);
  Get.put(ProductController(), permanent: true);

  runApp(const DisplayRoomShopApp());
}

class DisplayRoomShopApp extends StatelessWidget {
  const DisplayRoomShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Display Room Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1F5EFF),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF15171A),
          surfaceTintColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}
