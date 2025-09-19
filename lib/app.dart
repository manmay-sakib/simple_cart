import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'application/router/routes.dart';

class SimpleApp extends ConsumerWidget {
  const SimpleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider,
      title: "Simple Cart",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
    );
  }
}
