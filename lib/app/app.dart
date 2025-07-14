import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartest_man/features/blocks/data/repositories/bloc/structure_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/bloc/players_bloc.dart';

import 'package:smartest_man/features/blocks/data/repositories/blocks_repository.dart';
import 'package:smartest_man/features/blocks/presentation/hello_page.dart';
import 'package:smartest_man/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({required this.createPacksRepository, super.key});

  final StructureRepository Function() createPacksRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<StructureRepository>(
      create: (_) => createPacksRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) => GameStructureBloc(
                  repository: context.read<StructureRepository>(),
                )..add(OnInit()),
          ),
        ],
        child: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(child: Text('Ошибка: ${snapshot.error}')),
                ),
              );
            }

            final prefs = snapshot.data!;

            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => PlayersBloc(prefs: prefs)),
              ],
              child: const AppView(),
            );
          },
        ),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: HelloPage(),
    );
  }
}
