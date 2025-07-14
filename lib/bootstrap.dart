import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartest_man/app/app.dart';
import 'package:smartest_man/app/app_bloc_observer.dart';
import 'package:smartest_man/features/blocks/data/blocks_api/blocks_api.dart';
import 'package:smartest_man/features/blocks/data/repositories/blocks_repository.dart';

void bootstrap({required PacksApi packsApi}) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log(error.toString(), stackTrace: stack);
    return true;
  };

  Bloc.observer = const AppBlocObserver();

  runApp(
    App(
      createPacksRepository:
          () => StructureRepositoryImpl(api: packsApi, useMock: false),
    ),
  );
}
