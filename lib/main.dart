import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/cart_controller.dart';
import 'controllers/product_controller.dart';
import 'pages/dashboard_page.dart';
import 'theme/app_theme.dart';

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
      theme: AppTheme.light,
      home: const DashboardPage(),
    );
  }
}
