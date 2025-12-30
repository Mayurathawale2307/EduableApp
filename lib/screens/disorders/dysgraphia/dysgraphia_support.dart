import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/navigation_helper.dart';

class DysgraphiaSupport extends StatelessWidget {
  const DysgraphiaSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dysgraphia Support'),
        backgroundColor: const Color(0xFFA78BFA),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => NavigationHelper.navigateToHome(context),
        ),
      ),
      body: const Center(
        child: Text('Dysgraphia Support Resources'),
      ),
    );
  }
}

