import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/navigation_helper.dart';

class DyscalculiaResources extends StatelessWidget {
  const DyscalculiaResources({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dyscalculia Resources'),
        backgroundColor: const Color(0xFFFFB84D),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => NavigationHelper.navigateToHome(context),
        ),
      ),
      body: const Center(
        child: Text('Dyscalculia Learning Resources'),
      ),
    );
  }
}

