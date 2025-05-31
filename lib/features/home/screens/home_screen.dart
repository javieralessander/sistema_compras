import 'package:flutter/material.dart';
import '../../../shared/widgets/generic_appbar.dart';

class HomeScreen extends StatelessWidget {
  static const String name = 'home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text('Bienvenido al sistema de compras SICOM'),
            ),
          ),
        ],
      ),
    );
  }
}
