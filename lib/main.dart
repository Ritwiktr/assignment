import 'package:assignment/features/products/data/repositories/products_repository.dart';
import 'package:assignment/features/products/presentation/bloc/products_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment/features/audio/presentation/pages/audio_player_page.dart';
import 'package:assignment/features/form/presentation/pages/form_page.dart';
import 'package:assignment/features/products/presentation/pages/products_page.dart';
import 'features/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final productsRepository = ProductsRepository();

    return BlocProvider(
      create: (context) => ProductsBloc(repository: productsRepository),
      child: MaterialApp(
        title: 'Multi-Feature App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/form': (context) => const FormPage(),
          '/products': (context) => const ProductsPage(),
          '/audio': (context) => const AudioPlayerPage(),
        },
      ),
    );
  }
}
